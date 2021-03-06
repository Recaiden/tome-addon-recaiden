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
   name = _t"fire", type = "REK_DEML_FIRE_DIMINISHING",
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
	name = _t"blinding storm", type = "REK_DEML_STORM", text_color = "#F3C311#",
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

newDamageType{
	name = _t"dazing fire", type = "REK_DEML_FIRE_DAZE", text_color = "#FF3311#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		local realdam = DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam, state)
		if target and target:canBe("stun") then
			target:setEffect(target.EFF_DAZED, 2, {apply_power=src:combatSteampower()})
		end
		return realdam
	end,
}

newDamageType{
	name = _t"stunning fire", type = "REK_DEML_FIRE_STUN", text_color = "#FF3311#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		local realdam = DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam.dam, state)
		if target and target:canBe("stun") then
			target:setEffect(target.EFF_STUNNED, dam.dur, {apply_power=src:combatSteampower()})
		end
		return realdam
	end,
}

-- lightning that gives you max lightning pen
newDamageType{
	name = _t"gauss lightning", type = "REK_DEML_COILSHOCK",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		state = initState(state)
		if target then
			local old_pen = 0
			-- Cut resists
			local rLID = nil
			local rAID = nil
			if target.resists[DamageType.LIGHTNING] and target.resists[DamageType.LIGHTNING] > 0 then
				rLID = target:addTemporaryValue(
					"resists", {[DamageType.LIGHTNING]=-1 * (target.resists[DamageType.LIGHTNING] or 0)})
			end
			if target.resists.all and target.resists.all > 0 then
				rAID = target:addTemporaryValue(
					"resists", {all=-1 * (target.resists.all or 0)})
			end
			
			-- Damage
			DamageType:get(DamageType.LIGHTNING).projector(src, x, y, DamageType.LIGHTNING, dam, state)

			-- Restore resists
			if rLID then
				target:removeTemporaryValue("resists", rLID)
			end
			if rAID then
				target:removeTemporaryValue("resists", rAID)
			end
		end
	end,
}

-- shadow smoke but applies with summoner's steampower
newDamageType{
	name = _t"shadow smoke", type = "STEAM_SHADOW_SMOKE",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			local power = src.summoner and src.summoner:combatSteampower() or src:combatSteampower()
			target:setEffect(target.EFF_SHADOW_SMOKE, 5, {sight=dam, apply_power=power})
		end
	end,
}