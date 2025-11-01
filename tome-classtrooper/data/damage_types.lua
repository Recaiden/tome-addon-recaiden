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
	name = "laser", type = "REK_CARBINE_LIGHT",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)

		-- deal damage
		local realdam = DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam.dam, state)

		-- potential physical shrapnel damage
		if src and src.turn_procs and src.turn_procs.rek_oclt_dig then
			DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, src.turn_procs.rek_oclt_dig, state)
		end

		if dam.blind then
			if target:canBe("blind") then
				local check = src:combatBestpower()
				target:setEffect(target.EFF_BLINDED, dam.blind, {apply_power=(check), no_ct_effect=true})
			else
				game.logSeen(target, "%s resists the blinding light!", target:getName():capitalize())
			end
		end

		if dam.vuln then
			if target:canBe("blind") then
				local check = src:combatBestpower()
				target:setEffect(target.EFF_BLINDED, dam.blnid, {apply_power=(check), no_ct_effect=true})
			else
				game.logSeen(target, "%s resists the blinding light!", target:getName():capitalize())
			end
		end
		
		return realdam
	end,
}
