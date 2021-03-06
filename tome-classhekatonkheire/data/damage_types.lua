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