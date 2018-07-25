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

-- Physical + Blind and can accept numbers as well as tables
newDamageType{
   name = "blinding physical", type = "REK_WYRMIC_SAND",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      local chance = 25
      local dur = 3
      local perc = 50
      if _G.type(dam) == "table" then dam, dur, perc = dam.dam, dam.dur, (dam.initial or perc) end
      DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam, state)
      local target = game.level.map(x, y, Map.ACTOR)
      if target then
	 if target:canBe("blind") then
	    target:setEffect(target.EFF_BLINDED, dur, {apply_power=src:combatPhysicalpower(), apply_save="combatPhysicalResist"})
	 else
	    game.logSeen(target, "%s resists the sandstorm!", target.name:capitalize())
	 end
      end
   end,
}


-- Acid damage + Accuracy/Defense/Armor Down Corrosion but it doesn't show in the log.
newDamageType{
   name = "corrosive acid", type = "REK_SILENT_CORRODE",
   hideMessage=true,
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      if _G.type(dam) == "number" then dam = {dur = 4, armor = dam/2, defense = dam/2, dam = dam, atk=dam/2} end
      local target = game.level.map(x, y, Map.ACTOR)
      if target then
	 DamageType:get(DamageType.ACID).projector(src, x, y, DamageType.ACID, dam.dam, state)
	 target:setEffect(target.EFF_CORRODE, dam.dur, {atk=dam.atk, armor=dam.armor, defense=dam.defense, apply_power=src:combatMindpower()})
      end
   end,
}
