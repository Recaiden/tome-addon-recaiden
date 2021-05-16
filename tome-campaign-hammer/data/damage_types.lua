-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2016 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local initState = engine.DamageType.initState
local useImplicitCrit = engine.DamageType.useImplicitCrit

-- Physical damage + repulsion; checks for attack power against physical resistance
newDamageType{
	name = "pulse detonator", type = "PULSE_DETONATOR",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)

		local target = game.level.map(x, y, Map.ACTOR)
		if target and not state[target] then
			state[target] = true
			DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam, state)
			if target:checkHit(src:combatSteampower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(dam.x or src.x, dam.y or src.y, dam.dist)
				target:crossTierEffect(target.EFF_OFFBALANCE, src:combatSteampower())
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
			end
			if target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, dam.dur, {apply_power=src:combatSteampower()})
			end
		end
	end,
}

newDamageType{
	name = "darkness pull", type = "DARKNESS_PULL",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)

		local target = game.level.map(x, y, Map.ACTOR)
		if _G.type(dam) ~= "table" then dam = {dam=dam, dist=1, px = src.x, py = src.y} end
		if target then
			DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam.dam)
			if (dam.ignore_resist or target:checkHit(src:combatSpellpower(), target:combatSpellResist(), 0, 95, 15)) and target:canBe("knockback") then
				target:pull(dam.px, dam.py, dam.dist)
				if (not dam.silent) then
					game.logSeen(target, "%s is pulled!", target.name:capitalize())
				end
			else
				if (not dam.silent) then
					game.logSeen(target, "%s resists the pull!", target.name:capitalize())
				end
			end
		end
	end,
}

newDamageType{
	name = "darkness pin", type = "DARKNESS_PIN",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) ~= "table" then dam = {dam=dam, pin=4} end
		DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:canBe("pin") then
				target:setEffect(target.EFF_PINNED, dam.pin, {src=src, apply_power=src:combatSpellpower(), no_ct_effect=true})
			else
				game.logSeen(target, "%s resists!", target.name:capitalize())
			end
		end
	end,
}

newDamageType{
	name = "drain negative", type = "DRAIN_NEGATIVE",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam, factor=0.2} end
		local target = game.level.map(x, y, Map.ACTOR)
		local realdam = DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam.dam)
		if target and (realdam > 0 or dam.min) then
			local drain = (dam.min and math.max(dam.min, realdam * dam.factor)) or realdam * dam.factor
			src:incNegative(drain)
		end
	end,
}

--in short, effects must have damage, I use this for lucent wrath
newDamageType{
	name = "null_type", type="NULL_TYPE",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
	end,
}

--light and darkness in a mix
newDamageType{
	name = "light + dark", type = "LIGHT_DARK",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) ~= "table" then dam = {dam=dam, light_part=1/2} end
		local light_dam = DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam.dam * dam.light_part)
		local dark_dam  = DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam.dam * (1 - dam.light_part))
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if dam.slow and dark_dam > 0 then
				target:setEffect(target.EFF_SLOW_MOVE, 5, {apply_power=src:combatSpellpower(), power=dam.slow}, true)
			end if dam.slow and light_dam > 0 then
				target:setEffect(target.EFF_SLOW_TALENT, 5, {apply_power=src:combatSpellpower(), power=dam.slow * 0.6}, true)
			end
		end
	end,
}

-- Blight needles, physical damage + potential diseases
newDamageType{
	name = "blighted needles", type = "BLIGHTED_NEEDLES", text_color = "#DARK_GREEN#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:canBe("disease") and rng.percent(dam.disease_chance or 20) then
			local eff = rng.table{{target.EFF_ROTTING_DISEASE, "con"}, {target.EFF_DECREPITUDE_DISEASE, "dex"}, {target.EFF_WEAKNESS_DISEASE, "str"}}
			target:setEffect(eff[1], dam.dur or 5, { src = src, [eff[2]] = dam.disease_power or 5, dam = dam.disease_dam or (dam.dam / 5) })
		end
	end,
}

-- Corrupted blood, blight damage + potential diseases
newDamageType{
	name = "infective darkness", type = "MIASMA", text_color = "#DARK_GREEN#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:canBe("disease") and rng.percent(dam.disease_chance or 20) then
			local eff = rng.table{{target.EFF_ROTTING_DISEASE, "con"}, {target.EFF_DECREPITUDE_DISEASE, "dex"}, {target.EFF_WEAKNESS_DISEASE, "str"}}
			target:setEffect(eff[1], dam.dur or 5, { src = src, [eff[2]] = dam.disease_power or 5, dam = dam.disease_dam or (dam.dam / 5) })
		end
	end,
}

-- Regen steam, damage bleeding
newDamageType{
	name = "fiery vapour", type = "FIERY_VAPOUR", text_color = "#RED#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam, steam=3} end
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		if target:getMaxSteam() > 0 then
			target:incSteam(dam.steam)
		end
		if #target:effectsFilter({subtype={bleed=1}}, 1) > 0 then
			DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam.dam)
		end
	end,
}

-- Heals
newDamageType{
	name = "repairing", type = "REPAIR_MECHANICAL",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target.repairable then
			target:attr("allow_on_heal", 1)
			target:heal(dam, src)
			target:attr("allow_on_heal", -1)
		end
	end,
}

-- Heals
newDamageType{
	name = "mind drone", type = "MIND_DRONE",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and src:reactionToward(target) < 0 then
			target:setEffect(target.EFF_MIND_DRONE, 6, {apply_power=src:combatSteampower(), fail=dam.fail, reduction=dam.reduction})
		end
		return 0
	end,
}

-- Physical damage + repulsion; checks for attack power against physical resistance
newDamageType{
	name = "20% chance of physical repulsion", type = "THUNDERCLAP_COATING",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		state = initState(state)
		if _G.type(dam) ~= "table" then dam = {dam=dam, dist=3} end
		if target and not state[target] and rng.percent(20) then
			state[target] = true
			DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam, state)
			if target:checkHit(src:combatSteampower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
				target:knockback(dam.x or src.x, dam.y or src.y, dam.dist)
				target:crossTierEffect(target.EFF_OFFBALANCE, src:combatPhysicalpower())
				game.logSeen(target, "%s is knocked back!", target.name:capitalize())
			else
				game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
			end
		end
	end,
}

-- Heals on attack
newDamageType{
	name = "temporal ripples", type = "TEMPORAL_RIPPLES",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and src:reactionToward(target) < 0 then
			target:setEffect(target.EFF_TEMPORAL_RIPPLES, 2, {power=dam})
		end
		return 0
	end,
}

-- Heals on attack
newDamageType{
	name = "curse of amakthel", type = "CURSE_OF_AMAKTHEL",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and src:reactionToward(target) < 0 then
			target:setEffect(target.EFF_CURSE_OF_AMAKTHEL, 2, {power=dam})
		end
		return 0
	end,
}

-- Mind + Sear temp effect
newDamageType{
	name = "psionic searing", type = "PSIONIC_FOG",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		DamageType:get(DamageType.MIND).projector(src, x, y, DamageType.MIND, dam.dam)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(target.EFF_SEARED, 1, { apply_power=src:combatMindpower(), power=dam.sear or 10 })
		end
	end,
}

-- Damages a range of resources
newDamageType{
	name = "resource shock", type = "RESOURCE_SHOCK",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target.stamina then target:incStamina(-dam) end
			if target.mana then target:incMana(-dam) end
			if target.psi then target:incPsi(-dam) end
			if target.steam then target:incSteam(-dam) end
		end
	end,
}

newDamageType{
	name = "smoke cloud", type = "SMOKE_CLOUD",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if src:reactionToward(target) < 0 then
				if target:canBe("confusion") then
					local reapplied = target:hasEffect(target.EFF_CONFUSED)
					target:setEffect(target.EFF_CONFUSED, 2, { power=dam.dam, src=src }, reapplied)
				end
			else
				local reapplied = target:hasEffect(target.EFF_SMOKE_COVER)
				target:setEffect(target.EFF_SMOKE_COVER, 1, { power=dam.chance, stealth = dam.stealth }, reapplied)
			end
		end
	end,
}