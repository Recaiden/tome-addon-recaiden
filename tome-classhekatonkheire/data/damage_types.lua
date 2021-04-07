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

-- mind damage with 1 turn slow
newDamageType{
	name = _t"stare", type = "REK_HEKA_STARE",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local dur = 1
		local slow = 0.1
		if _G.type(dam) == "table" then dam, slow = dam.dam, dam.slow end
		DamageType:get(DamageType.MIND).projector(src, x, y, DamageType.MIND, dam, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(target.EFF_SLOW, dur, {power=slow, no_ct_effect=true})
		end
	end,
}