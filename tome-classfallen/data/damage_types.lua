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
      end

      if target:checkHit(src:combatPhysicalpower(), target:combatPhysicalResist(), 0, 95, 5) and target:canBe("knockback") then
	 target:pull(src.x, src.y, 1)
	 game.logSeen(target, "%s is pulled in!", target.name:capitalize())
      else
	 game.logSeen(target, "%s resists the gravity!", target.name:capitalize())
      end
      
      DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam, state)
   end,
}
