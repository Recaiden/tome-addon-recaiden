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

removeGroundEffect = function(eff)
   local e = eff
   --pop the effect on the ground
   if e.particles then
      for j, ps in ipairs(e.particles) do game.level.map:removeParticleEmitter(ps) end
   end
   if e.overlay then
      game.level.map.z_effects[e.overlay.zdepth][e] = nil
   end
   for i, ee in ipairs(game.level.map.effects) do
      if ee == e then
         table.remove(game.level.map.effects, i)
         break
      end
   end
end

newDamageType{
   name = "healing guidance", type = "REK_MTYR_GUIDE_HEAL",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      local target = game.level.map(x, y, Map.ACTOR)
      if target then         
         -- if this is their guiding light
         local eff = target:hasEffect(target.EFF_REK_MTYR_GUIDANCE_AVAILABLE)
         if eff then
            -- do the bonus
            target:setEffect(target.EFF_REK_MTYR_GUIDANCE_HEAL, 3, {power=dam})
            target:removeEffect(target.EFF_REK_MTYR_GUIDANCE_AVAILABLE)

            -- do the upgrade
            if target:knowTalent(target.T_REK_MTYR_WHISPERS_WARNING) then
               local t3 = target:getTalentFromId(target.T_REK_MTYR_WHISPERS_WARNING)
            end
            
            if eff.ground_effect then
               removeGroundEffect(eff.ground_effect)
               -- local e = eff.ground_effect
               -- --pop the effect on the ground
               -- 	if e.particles then
               --     for j, ps in ipairs(e.particles) do game.level.map:removeParticleEmitter(ps) end
               --  end
               --  if e.overlay then
               --     game.level.map.z_effects[e.overlay.zdepth][e] = nil
               --  end
               --  for i, ee in ipairs(game.level.map.effects) do
               --     if ee == e then
               --        table.remove(game.level.map.effects, i)
               --        break
               --     end
               --  end
                --engine function not yet available.
                --game.level.map:removeEffect(e)
            end
	 end
      end
   end,
}

newDamageType{
   name = "healing guidance", type = "REK_MTYR_GUIDE_BUFF",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      local target = game.level.map(x, y, Map.ACTOR)
      if target then         
         -- if this is their guiding light
         local eff = target:hasEffect(target.EFF_REK_MTYR_GUIDANCE_AVAILABLE)
         if eff then
            -- do the bonus
            if not target:attr("no_talents_cooldown") then
               for tid, _ in pairs(target.talents_cd) do
                  local t = target:getTalentFromId(tid)
                  if t and not t.fixed_cooldown then
                     target.talents_cd[tid] = math.max(0, target.talents_cd[tid] - math.ceil(power/20))
                  end
               end
            end
            target:removeEffect(target.EFF_REK_MTYR_GUIDANCE_AVAILABLE)

            -- do the upgrade
            if target:knowTalent(target.T_REK_MTYR_WHISPERS_WARNING) then
               local t3 = target:getTalentFromId(target.T_REK_MTYR_WHISPERS_WARNING)
            end
            
            if eff.ground_effect then
               removeGroundEffect(eff.ground_effect)
            end
	 end
      end
   end,
             }

newDamageType{
   name = "visionary guidance", type = "REK_MTYR_GUIDE_FLASH",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      local target = game.level.map(x, y, Map.ACTOR)
      if target then         
         -- if this is their guiding light
         local eff = target:hasEffect(target.EFF_REK_MTYR_GUIDANCE_AVAILABLE)
         if eff then
            -- do the bonus
            target:setEffect(target.EFF_REK_MTYR_GUIDANCE_FLASH, 3, {power=dam*0.5})
            target:removeEffect(target.EFF_REK_MTYR_GUIDANCE_AVAILABLE)

            -- do the upgrade
            if target:knowTalent(target.T_REK_MTYR_WHISPERS_WARNING) then
               local t3 = target:getTalentFromId(target.T_REK_MTYR_WHISPERS_WARNING)
            end
            
            if eff.ground_effect then
               removeGroundEffect(eff.ground_effect)
            end
	 end
      end
   end,
}