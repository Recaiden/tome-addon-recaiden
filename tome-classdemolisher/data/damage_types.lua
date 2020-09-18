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

-- Fire that doesn't stack well
newDamageType{
   name = "fire", type = "REK_DEML_FIRE_DIMINISHING",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      local target = game.level.map(x, y, Map.ACTOR)
			if target:hasProc("explosive_charge_resist") then dam = dam * 0.6 end
      if target then
				DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam, state)
				target:setProc("explosive_charge_resist", 1)
      end
   end,
}

newDamageType{
	name = "blinding storm", type = "REK_DEML_STORM", text_color = "#F3C311#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local chance = 25
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:hasEffect(target.EFF_SHOCKED) then chance = 50 end
		local realdam = DamageType:get(DamageType.LIGHTNING).projector(src, x, y, DamageType.LIGHTNING, dam, state)
		if target and rng.percent(chance) then
			if target:canBe("blind") then
				local power = src.summoner and src.summoner:combatSteampower() or src:combatSteampower()
				target:setEffect(target.EFF_BLINDED, 3, {src=src, apply_power=power})
			end
		end
		return realdam
	end,
}