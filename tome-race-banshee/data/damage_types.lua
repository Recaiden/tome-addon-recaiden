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


-- Handles immunity check for banshee wail effects
newDamageType{
   name = "banshee wail", type = "REK_BANSHEE_WAIL",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      local target = game.level.map(x, y, Map.ACTOR)
      if target then
	 local power = math.max(src:combatSpellpower(), src:combatMindpower(), src:combatPhysicalpower())
	 if target:canBe("confusion") then
	    target:setEffect(target.EFF_CONFUSED, dam.dur, {power=dam.dam or 30, apply_power=power})
	 else
	    game.logSeen(target, "%s resists the confusion!", target.name:capitalize())
	 end
	 if target:canBe("silence") then
	    target:setEffect(target.EFF_SILENCED, dam.dur, {apply_power=power, min_dur=1}, true)
	 else
	    game.logSeen(target, "%s resists the silence!", target.name:capitalize())
	 end
	 -- Extra stack of curse
	 if src:knowTalent(src.T_REK_BANSHEE_CURSE) then
	    local t2 = src:getTalentFromId(src.T_REK_BANSHEE_CURSE)
	    target:setEffect(target.EFF_REK_BANSHEE_CURSE, 5, {max_stacks = t2.maxStacks(src, t2)}, true)
	 end
      end
   end,
}
