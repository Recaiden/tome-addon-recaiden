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
   name = "black-hole gravity", type = "REK_FLN_GRAVITY_PULL",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      if _G.type(dam) == "number" then dam = {dam=dam} end
      local target = game.level.map(x, y, Map.ACTOR)
      if not target then return end
      if target then
	 if target:isTalentActive(target.T_GRAVITY_LOCUS) then return end
	 if dam.slow then
	    target:setEffect(target.EFF_SLOW, dam.dur, {power=dam.slow, apply_power=src:combatPhysicalpower(), no_ct_effect=true})
	 end
         if src:isTalentActive(src.T_FLN_BLACKSUN_SINGULARITY) then
            target:setEffect(target.EFF_ANTI_GRAVITY, 2, {})
         end
      end

      if target:checkHit(src:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 5) and target:canBe("knockback") then
         local source = src.__project_source or src
	 target:pull(source.x, source.y, 2)
	 game.logSeen(target, "%s is pulled in!", target.name:capitalize())
      else
	 game.logSeen(target, "%s resists the gravity!", target.name:capitalize())
      end
      
      DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam, state)
   end,
}

newDamageType{
   name = "solar blood", type = "FLN_TEMPLAR_SIGIL",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      local target = game.level.map(x, y, Map.ACTOR)
      if target then
	 if target == src then
	    target:setEffect(target.EFF_BLAZING_LIGHT, 1, {power = 2, no_ct_effect=true})
	 elseif target:reactionToward(src) < 0 then
	    target:setEffect(target.EFF_FLN_BLINDING_LIGHT, 1, {src=src, power=dam.dam, apply_power=dam.pow, no_ct_effect=true})
            DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam.dam, state)
	 end
      end
   end,
}
