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

-- Mind that only hits enemies
newDamageType{
   name = "mind", type = "REK_MTYR_MIND_FRIENDS",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      if src and src:getInsanity() then
         dam = dam * (1 + src:getInsanity()/100)
      end
      local target = game.level.map(x, y, Map.ACTOR)
      if target and src:reactionToward(target) < 0 then
         DamageType:get(DamageType.MIND).projector(src, x, y, DamageType.MIND, dam, state)
      end
   end,
}

removeGroundEffect = function(e)
	if not e then return end
	--e.duration = 0
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

applyGuidanceBurn = function(target, t)
   local dur = t.getDuration(target, t)
   local dam = target:mindCrit(t.getDamage(target, t))
   -- Add a lasting map effect
   local ef = game.level.map:addEffect(target,
                                       target.x, target.y, dur,
                                       DamageType.REK_MTYR_MIND_FRIENDS, dam,
                                       2,
                                       5, nil,
                                       nil,
                                       function(e)
                                          e.x = e.src.x
                                          e.y = e.src.y
                                          return true
                                       end,
                                       0, 0
                                      )
    ef.name = "warning lights"

    game.level.map:addEffect(target,
                                       target.x, target.y, dur,
                                       DamageType.COSMETIC, 0,
                                       0,
                                       5, nil,
                                       {type="mindstorm", only_one=true},
                                       function(e)
                                          e.x = e.src.x
                                          e.y = e.src.y
                                          return true
                                       end,
                                       0, 0
                                      )
                
  
end

newDamageType{
   name = "healing guidance", type = "REK_MTYR_GUIDE_HEAL",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      local target = game.level.map(x, y, Map.ACTOR)
      if target and target == src then         
         -- do the bonus
         target:setEffect(target.EFF_REK_MTYR_GUIDANCE_HEAL, 3, {power=dam})
         
         -- do the upgrade
         if target:knowTalent(target.T_REK_MTYR_WHISPERS_WARNING) then
            local t3 = target:getTalentFromId(target.T_REK_MTYR_WHISPERS_WARNING)
            applyGuidanceBurn(target, t3)
         end
         
         local geff = game.level.map:hasEffectType(x, y, DamageType.REK_MTYR_GUIDE_HEAL)
         if geff then
            removeGroundEffect(geff)
            game.level.map:particleEmitter(x, y, 2, "generic_sploom", {rm=20, rM=20, gm=160, gM=180, bm=20, bM=20, am=35, aM=90, radius=2, basenb=30})
         end
         game:playSoundNear(target, "talents/heal")
      end
   end,
}

newDamageType{
   name = "energizing guidance", type = "REK_MTYR_GUIDE_BUFF",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      local target = game.level.map(x, y, Map.ACTOR)
      if target and target == src then         
         -- do the bonus
         if not target:attr("no_talents_cooldown") then
            for tid, _ in pairs(target.talents_cd) do
               local t = target:getTalentFromId(tid)
               if t and not t.fixed_cooldown then
                  target.talents_cd[tid] = math.max(0, target.talents_cd[tid] - math.max(1, math.floor(dam/25)))
               end
            end
         end
         
         -- do the upgrade
         if target:knowTalent(target.T_REK_MTYR_WHISPERS_WARNING) then
            local t3 = target:getTalentFromId(target.T_REK_MTYR_WHISPERS_WARNING)
            applyGuidanceBurn(target, t3)
         end
         
         local geff = game.level.map:hasEffectType(x, y, DamageType.REK_MTYR_GUIDE_BUFF)
         if geff then
            removeGroundEffect(geff)
            game.level.map:particleEmitter(x, y, 2, "generic_sploom", {rm=10, rM=30, gm=90, gM=110, bm=235, bM=255, am=35, aM=90, radius=2, basenb=30})
         end
         game:playSoundNear(target, "talents/distortion")
      end
   end,
}

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