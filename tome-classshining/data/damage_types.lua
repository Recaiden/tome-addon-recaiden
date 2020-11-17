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
   name = "destructive guidance", type = "REK_MTYR_GUIDE_FLASH",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      local target = game.level.map(x, y, Map.ACTOR)
      if target and target == src then         
         -- do the bonus
         target:setEffect(target.EFF_REK_MTYR_GUIDANCE_FLASH, 3, {power=dam*0.25})
         
         -- do the upgrade
         if target:knowTalent(target.T_REK_MTYR_WHISPERS_WARNING) then
            local t3 = target:getTalentFromId(target.T_REK_MTYR_WHISPERS_WARNING)
            applyGuidanceBurn(target, t3)
         end
         
         local geff = game.level.map:hasEffectType(x, y, DamageType.REK_MTYR_GUIDE_FLASH)
         if geff then
            removeGroundEffect(geff)
            game.level.map:particleEmitter(x, y, 2, "generic_sploom", {rm=235, rM=255, gm=200, gM=220, bm=50, bM=70, am=35, aM=90, radius=2, basenb=30})
         end
         game:playSoundNear(target, "talents/tidalwave")
      end
   end,
}