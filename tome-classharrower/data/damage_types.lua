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
	name = "blinding crystal light", type = "REK_GLR_CRYSTAL_LIGHT",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		-- light grids
		DamageType:get(DamageType.LITE).projector(src, x, y, DamageType.LITE, 1, state)

		local power = src:combatMindpower()
		local dur = 3
		if _G.type(dam) == "table" then dam, power, dur = dam.dam, dam.power, dam.dur end
		
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, math.ceil(dur), {apply_power=power, no_ct_effect=true})
			elseif target.getName then
				game.logSeen(target, "%s resists the blinding light!", target:getName():capitalize())
			end
		end
		-- deal damage
		return DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam, state)
	end,
}