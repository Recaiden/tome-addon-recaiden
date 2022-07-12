function DamageType.initState(state)
	if state == nil then return {}
	elseif state == true or state == false then return {}
	else return state end
end

-- Loads the implicit crit if one has not been passed.
function DamageType.useImplicitCrit(src, state)
	if state.crit_set then return end
	state.crit_set = true
	if not src.turn_procs then
		state.crit_type = false
		state.crit_power = 1
	else
		state.crit_type = src.turn_procs.is_crit
		state.crit_power = src.turn_procs.crit_power or 1
		src.turn_procs.is_crit = nil
		src.turn_procs.crit_power = nil
	end
end

local useImplicitCrit = DamageType.useImplicitCrit
local initState = DamageType.initState

newDamageType{
	name = _t"divided arms", type = "REK_HEKA_DIVIDED_ARMS_MARKER", text_color = "#BROWN#",
	projector = function(src, x, y, type, dam) end,
	death_message = {_t"hugged"},
}

newDamageType{
	name = _t"pit", type = "REK_HEKA_PIT", text_color = "#BLACK#",
	projector = function(src, x, y, type, dam) end,
	death_message = {_t"dropped"},
}

newDamageType{
	name = _t"pillar", type = "REK_HEKA_PILLAR", text_color = "#BLACK#",
	projector = function(src, x, y, type, dam) end,
	death_message = {_t"stoned"},
}

newDamageType{
	name = _t"pylon", type = "REK_HEKA_PYLON_MARKER", text_color = "#BLACK#",
	projector = function(src, x, y, type, dam) end,
	death_message = {_t"astrologized"},
}

-- mind damage with 1 turn slow
newDamageType{
	name = _t"stare", type = "REK_HEKA_STARE",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local dur = 1
		local slow = 0.1
		local overwatch = 0
		local multiplier = 1
		if _G.type(dam) == "table" then dam, slow, overwatch, multiplier = dam.dam, dam.slow, dam.overwatch, dam.multiplier end
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if src:reactionToward(target) <= 0 then
				local mult = 1
				local multdam = 1
				
				if target.turn_procs and target.turn_procs.rek_heka_stared_at then
					for eyeid, v in pairs(target.turn_procs.rek_heka_stared_at) do
						if eyeid ~= src.uid then
							mult = multiplier
							multdam = multiplier * 2 - 1
							target:setProc("heka_panopticon_ready", 2)
							break
						end
					end
				end
				target.turn_procs = target.turn_procs or {}
				target.turn_procs.rek_heka_stared_at = target.turn_procs.rek_heka_stared_at or {}
				target.turn_procs.rek_heka_stared_at[src.uid] = true
				
				target:setEffect(target.EFF_SLOW, dur, {power=slow*mult, no_ct_effect=true})	
				DamageType:get(DamageType.MIND).projector(src, x, y, DamageType.MIND, dam*multdam, state)
			elseif overwatch > 0  then
				target:setEffect(target.EFF_REK_HEKA_OVERWATCH, 2, {power=overwatch, src=src})
			end
		end
	end,
}

-- physical damage with variable-length disarm
newDamageType{
	name = _t"lens", type = "REK_HEKA_LENS",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local dur = 1
		if _G.type(dam) == "table" then dam, dur = dam.dam, dam.dur end
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:canBe("disarm") then
				target:setEffect(target.EFF_DISARMED, dur, {src=src, apply_power=src:combatSpellpower()})
			end
			DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam, state)
		end
	end,
}

-- physical damage with physical numbing
newDamageType{
	name = _t("stinging", "damage type"), type = "REK_HEKA_PHYSICAL_NUMB", text_color = "#GREY#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(target.EFF_REK_HEKA_SPEARED, dam.dur, {power=dam.numb, apply_power=src:combatSpellpower()})
		end
		return DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam, state)
	end,
}

-- arcane damage with slow
newDamageType{
	name = _t("rift", "damage type"), type = "REK_HEKA_ARCANE_SLOW", text_color = "#WHITE#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam, power=0.15} end
		DamageType:get(DamageType.ARCANE).projector(src, x, y, DamageType.ARCANE, dam.dam, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(target.EFF_SLOW, 3, {power=dam.power, no_ct_effect=true})
		end
	end,
}

-- Physical + spellpower stun
newDamageType{
	name = _t("spider stab", "damage type"), type = "REK_HEKA_PHYSICAL_STUN",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 2, {src=src, apply_power=src:combatSpellpower(), min_dur=1})
			else
				game.logSeen(target, "%s resists the stun!", target:getName():capitalize())
			end
		end
	end,
}

-- Mind + potential talentfail
newDamageType{
	name = _t("mind", "damage type"), type = "REK_HEKA_MIND_CRIPPLE",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		DamageType:get(DamageType.MIND).projector(src, x, y, DamageType.MIND, dam, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and src and src.knowTalent and src:knowTalent(src.T_REK_HEKA_OCEANSONG_FAIL) then
			local power = src:callTalent(src.T_REK_HEKA_OCEANSONG_FAIL, "getFail")
			target:setEffect(target.EFF_REK_HEKA_LULLABY, 1, {src=src, apply_power=src:combatSpellpower(), apply_save="combatSpellResist", power=power, no_ct_effect=true})
		end
	end,
}


-- Mind + spellpower confuse
newDamageType{
	name = _t("music", "damage type"), type = "REK_HEKA_MIND_HARMONY",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		DamageType:get(DamageType.REK_HEKA_MIND_CRIPPLE).projector(src, x, y, DamageType.REK_HEKA_MIND_CRIPPLE, dam, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:canBe("confusion") then
				target:setEffect(target.EFF_CONFUSED, 3, {src=src, apply_power=src:combatSpellpower(), power=33})
			else
				game.logSeen(target, "%s resists the confusion!", target:getName():capitalize())
			end
		end
	end,
}

-- physical damage with more damage per positive or negative effect
-- damage should be table of dam (base damage) and amp (fraction of bonus damage per effect)
newDamageType{
	name = _t("radiance", "damage type"), type = "REK_HEKA_PHYSICAL_PUNISHMENT", text_color = "#WHITE#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		local amp = 1
		if target then
			local effs = target:effectsFilter({types={physical=true, magical=true, mental=true}}, 7)
			local nb = #effs or 0
			amp = (1 + dam.amp * nb)
		end
		return DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam * amp, state)
	end,
}

-- Arcane/Darkness damage
newDamageType{
	name = _t("magical darkness", "damage type"), type = "REK_HEKA_OUBLIETTE", text_color = "#GREY#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if src:reactionToward(target) <= 0 then	
				DamageType:get(DamageType.ARCANE).projector(src, x, y, DamageType.ARCANE, dam / 2, state)
				DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam / 2, state)
			end
		end
	end,
}
