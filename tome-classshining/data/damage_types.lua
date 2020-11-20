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
	name = _t"weakening light", type = "REK_SHINE_LIGHT_WEAK", text_color = "#GOLD#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local realdam = DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam.dam, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and src:reactionToward(target) < 0 then
			target:setEffect(target.EFF_REK_SHINE_RADIANT_WEAKNESS, 1, {power=dam.power, src=src, apply_power=src:combatSpellpower(), no_ct_efffect=true})
		end
		return realdam
	end,
}

newDamageType{
	name = _t"stunning light", type = "REK_SHINE_LIGHT_STUN", text_color = "#GOLD#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local realdam = DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:canBe("stun") then
			target:setEffect(target.EFF_STUNNED, 3, {src=src, apply_power=src:combatSpellpower()})
		end
		return realdam
	end,
}

newDamageType{
	name = _t"mirror barrier", type = "REK_SHINE_MIRROR", text_color = "#GOLD#",
	projector = function(src, x, y, type, dam) end,
	death_message = {_t"reflected"},
}