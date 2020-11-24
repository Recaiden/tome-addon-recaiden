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
	name = _t"light of the citadel", type = "REK_SHINE_SEAL", text_color = "#GOLD#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam, knock=true, disarm=false} end
		local target = game.level.map(x, y, Map.ACTOR)
		if target == src then target:setEffect(target.EFF_SANCTITY, 1, {src=src}) end
		if target and src:reactionToward(target) < 0 then
			local realdam = DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam.dam, state)
			if dam.damFire then realdam = realdam + DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam.damFire, state) end
			if dam.disarm == true and target:canBe("disarm") then
				target:setEffect(target.EFF_DISARMED, dam.dur or 3, {src=src, apply_power=src:combatSpellpower(), no_ct_effect=true})
			end
			if dam.knock == true and target:canBe("knockback") and target:checkHit(src:combatSpellpower(), target:combatMentalResist(), 0, 95, 5) then
				target:knockback(src.x, src.y, 2)
				target:crossTierEffect(target.EFF_BRAINLOCKED, src:combatSpellpower())
				game.logSeen(target, "%s is knocked back!", target:getName():capitalize())
			end
			return realdam
		end
		return 0
	end,
}

newDamageType{
	name = _t"burning light", type = "REK_SHINE_SEAL_WALK", text_color = "#GOLD#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam, numb=10} end
		local target = game.level.map(x, y, Map.ACTOR)
		if target and src:reactionToward(target) < 0 then
			local realdam = DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam.dam, state)
			realdam = realdam + DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam, state)
			target:setEffect(target.EFF_WEIGHT_OF_THE_SUN, 3, {reduce=dam.numb, src=src, apply_power=src:combatSpellpower(), no_ct_effect=true})
			return realdam
		end
		return 0
	end,
}

newDamageType{
	name = _t"mirror barrier", type = "REK_SHINE_MIRROR", text_color = "#GOLD#",
	projector = function(src, x, y, type, dam) end,
	death_message = {_t"reflected"},
}