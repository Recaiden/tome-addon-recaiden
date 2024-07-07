function DamageType.initState(state)
   if state == nil then return {}
   elseif state == true or state == false then return {}
   else return state end
end

rekWyrmicSurge = function(self, tg, damage_inc)
   if not self:knowTalent(self.T_REK_WYRMIC_ELEC_CHAIN) then return end
   if not tg then return end

   local fx, fy = tg.x, tg.y
   if not fx or not fy then return end

   local diminish = self:callTalent(self.T_REK_WYRMIC_ELEC_CHAIN, "getPercent")
   local nb = self:callTalent(self.T_REK_WYRMIC_ELEC_CHAIN, "getNumChain")
   local affected = {}
   local first = nil
   local dam = damage_inc
   
   self:project(tg, fx, fy, function(dx, dy)
		   local actor = game.level.map(dx, dy, Map.ACTOR)
		   if actor and not affected[actor] then
		      affected[actor] = true
		      first = actor
		      
		      self:project({type="ball", selffire=true, x=dx, y=dy, radius=5, range=0}, dx, dy, function(bx, by)
			    local actor = game.level.map(bx, by, Map.ACTOR)
			    if actor and not affected[actor] then
			       affected[actor] = true
			    end
		      end)
		      return true
		   end
   end)

   if not first then return end
   local targets = { }
   affected[self] = nil
   affected[tg] = nil
   local possible_targets = table.listify(affected)
   for i = 1, nb do
      if #possible_targets == 0 then break end
      local act = rng.tableRemove(possible_targets)
      targets[#targets+1] = act[1]
   end
   
   local sx, sy = tg.x, tg.y
   for i, actor in ipairs(targets) do
      local tgr = {type="beam", range=5, selffire=false, talent=t, x=sx, y=sy}

      -- Decrease damage with each jump, no new variability.
      if i > 1 then
         dam = dam * 0.75
      else
         dam = dam * diminish / 100
      end
      
      self:project(tgr, actor.x, actor.y, DamageType.LIGHTNING, dam)
      
      if core.shader.active() then game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "lightning_beam", {tx=actor.x-sx, ty=actor.y-sy}, {type="lightning"})
      else game.level.map:particleEmitter(sx, sy, math.max(math.abs(actor.x-sx), math.abs(actor.y-sy)), "lightning_beam", {tx=actor.x-sx, ty=actor.y-sy})
      end
      
      sx, sy = actor.x, actor.y
   end

end


rekWyrmicElectrocute = function(self, target)
   if self:knowTalent(self.T_REK_WYRMIC_ELEC) then
      if not target then return end
      if target:hasEffect(self.EFF_REK_WYRMIC_NO_STATIC) then return end
      self:project(target, target.x, target.y, function(px, py)
		      if not target:checkHit(self:combatMindpower(), target:combatPhysicalResist(), 10) then
			 game.logSeen(target, "%s resists the static field!", target.name:capitalize())
			 return
		      end
		      target:setEffect(self.EFF_REK_WYRMIC_NO_STATIC, 20, {})
		      game.logSeen(target, "%s is caught in the static field!", target.name:capitalize())
		      local perc = self:callTalent(self.T_REK_WYRMIC_ELEC, "getPercent")
		      if target.rank >= 5 then perc = perc / 2.5
		      elseif target.rank >= 3.5 then perc = perc / 2
		      elseif target.rank >= 3 then perc = perc / 1.5
		      end
		      
		      local dam = target.life * perc / 100
		      if target.life - dam < 0 then dam = target.life end
		      target:takeHit(dam, self)
		      
		      game:delayedLogDamage(self, target, dam, ("#PURPLE#%d STATIC#LAST#"):format(math.ceil(dam)))
					      end,
		   nil)
      --game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "shout", {additive=true, life=10, size=3, distorion_factor=0.5, radius=self:getTalentRadius(t), nb_circles=8, rm=0, rM=0, gm=0, gM=0, bm=0.7, bM=0.9, am=0.4, aM=0.6})
      game:playSoundNear(self, "talents/lightning")
   end
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

-- Fire damage + DOT + Flameshock
newDamageType{
   name = "stunning fire", type = "REK_WYRMIC_FIRE", text_color = "#LIGHT_RED#",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      if _G.type(dam) == "number" then
	 dam = {dam=dam, chance=25, perc=80, dur=3}
      end
      if not dam.perc then
	 dam.perc = 80
      end
      local target = game.level.map(x, y, Map.ACTOR)

      --Static Damage
      if target then
	 rekWyrmicElectrocute(src, target)
      end
      
      local init_dam = dam.dam * dam.perc / 100
      local realdam = 0
      if init_dam > 0 then
	  realdam = DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, init_dam, state)
      end
      if target then
	 if dam.drain and not src:attr("dead") then
	    src:heal(realdam * dam.drain, target)
	 end
	 
	 local dam_burn = dam.dam * (110 - dam.perc) / 100
	 if rng.percent(dam.chance) then
	    -- Go for Flameshock
	    if target:canBe("stun") then
	       target:setEffect(target.EFF_STUNNED, dam.dur, {apply_power=src:combatMindpower(1, nil, 0)})
	    else
	       game.logSeen(target, "%s resists the searing flame!", target.name:capitalize())
	    end
	 end
	 target:setEffect(target.EFF_BURNING, dam.dur, {src=src, power=dam_burn / dam.dur, no_ct_effect=true})
      end
      return init_dam
   end,
}

-- Knockback wyrmicfire
newDamageType{
   name = "wyrmic fire repulsion", type = "REK_WYRMIC_FIRE_KNOCKBACK",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      local target = game.level.map(x, y, Map.ACTOR)
      if _G.type(dam) ~= "table" then dam = {dam=dam, dist=3} end
      state = initState(state)
      if target and not state[target] then
	 state[target] = true
	 DamageType:get(DamageType.REK_WYRMIC_FIRE).projector(src, x, y, DamageType.REK_WYRMIC_FIRE, {dam=dam.dam, chance=100, perc=80, dur=3}, state)
	 if target:checkHit(src:combatMindpower(), target:combatPhysicalResist(), 0, 95, 15) and target:canBe("knockback") then
	    target:knockback(src.x, src.y, dam.dist)
	    target:crossTierEffect(target.EFF_OFFBALANCE, src:combatMindpower())
	    game.logSeen(target, "%s is knocked back!", target.name:capitalize())
	 else
	    game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
	 end
      end
   end,
}

-- Cold damage + freeze chance + 20% slow
newDamageType{
	name = "slowing ice", type = "REK_WYRMIC_COLD", text_color = "#1133F3#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then
			dam = {dam=dam, chance=25, dur=2}
		else
			dam.dur = math.max(dam.dur-1, 1)
		end
		local target = game.level.map(x, y, Map.ACTOR)
		
		--Static Damage
		if target then
			rekWyrmicElectrocute(src, target)
		end
		
		local realdam = 0
		realdam = DamageType:get(DamageType.COLD).projector(src, x, y, DamageType.COLD, dam.dam, state)
		if target then
			if dam.drain and not src:attr("dead") then
				src:heal(realdam * dam.drain, target)
			end
			if rng.percent(dam.chance) then
				target:setEffect(target.EFF_SLOW, 3, {power=0.2, no_ct_effect=true})
	    if target:canBe("stun") then
				target:setEffect(target.EFF_FROZEN, dam.dur, {hp=105 + dam.dam * 1.5, apply_power=src:combatMindpower(1, nil, 0), min_dur=1})
				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, "Frozen!", {0,255,155})
	    else
				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, "Resist!", {0,255,155})
				game.logSeen(target, "%s resists!", target.name:capitalize())
	    end
			end
		end
		return realdam
	end,
}

-- Lightning damage + daze chance
-- If they're dazed, reapply the daze.  They get a save each time, but the AoE may last
newDamageType{
   name = "dazing storm", type = "REK_WYRMIC_ELEC", text_color = "#ROYAL_BLUE#",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      if _G.type(dam) == "number" then
	 dam = {dam=dam, chance=25, dur=3}
      end
      local dazed = false
      local target = game.level.map(x, y, Map.ACTOR)
      if target and target:hasEffect(target.EFF_DAZED) then
	 dazed = true
      end

      local realdam = rng.avg(dam.dam*0.6, dam.dam*1.4, 3)

      --chain
      rekWyrmicSurge(src, target, realdam)
      
      --Static Damage
      if target then
	 rekWyrmicElectrocute(src, target)
      end
      
      --Actual hit
      realdam = DamageType:get(DamageType.LIGHTNING).projector(src, x, y, DamageType.LIGHTNING, realdam, state)
      if target then
	 if dam.drain and not src:attr("dead") then
	    src:heal(realdam * dam.drain, target)
	 end
      end

      -- Average 3 turns of daze when it's being repeatedly reapplied.
      if dazed and dam.chance < 76 then
	 dam.chance = 76
      end

      if target and rng.percent(dam.chance) then
	 if target:canBe("stun") then
	    game:onTickEnd(function() target:setEffect(target.EFF_DAZED, dam.dur, {src=src, apply_power=src:combatMindpower(1, nil, 0)}) end) -- Do it at the end so we don't break our own daze
	 else
	    game.logSeen(target, "%s resists!", target.name:capitalize())
	 end
      end
      return realdam
   end,
}

-- Physical only
newDamageType{
	name = "soft sand", type = "REK_WYRMIC_NULL", text_color = "#WHITE#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then
			dam = {dam=dam, chance=25, dur=3}
		end
		
		local realdam = DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.FIRE, dam.dam, state)
		local target = game.level.map(x, y, Map.ACTOR)
		return realdam
	end,
}

-- Physical + Blind and can accept numbers as well as tables
newDamageType{
   name = "sand", type = "REK_WYRMIC_SAND",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      if _G.type(dam) == "number" then
	 dam = {dam=dam, chance=25, dur=3}
      end
      
      local target = game.level.map(x, y, Map.ACTOR)

      --Static Damage
      if target then
	 rekWyrmicElectrocute(src, target)
      end 
      
      local realdam = DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, dam.dam, state)
      if target then
	 if dam.drain and not src:attr("dead") then
	    src:heal(realdam * dam.drain, target)
	 end
	 if rng.percent(dam.chance) then
	    if target:canBe("blind") then
	       target:setEffect(target.EFF_BLINDED, dam.dur, {apply_power=src:combatMindpower(1, nil, 0), apply_save="combatPhysicalResist"})
	    else
	       game.logSeen(target, "%s resists the sandstorm!", target.name:capitalize())
	    end
	 end
      end
      return realdam
   end,
}

newDamageType{
   name = "disarming acid", type = "REK_WYRMIC_ACID", text_color = "#GREEN#",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      if _G.type(dam) == "number" then
	 dam = {chance=25, dam=dam, dur=3}
      end
      local target = game.level.map(x, y, Map.ACTOR)

      --Static Damage
      if target then
	 rekWyrmicElectrocute(src, target)
      end
      
      local realdam = DamageType:get(DamageType.ACID).projector(src, x, y, DamageType.ACID, dam.dam, state)
      if target then
	 if dam.drain and not src:attr("dead") then
	    src:heal(realdam * dam.drain, target)
	 end
      end
      if target and rng.percent(dam.chance) then
	 if target:canBe("disarm") then
	    target:setEffect(target.EFF_DISARMED, dam.dur or 3, {src=src, apply_power=src:combatMindpower(1, nil, 0)})
	 else
	    game.logSeen(target, "%s resists disarming!", target.name:capitalize())
	 end
      end
      return realdam
   end,
}


-- Crippling poison: failure to act
newDamageType{
   name = "crippling venom", type = "REK_WYRMIC_VENM", text_color = "#LIGHT_GREEN#",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      if _G.type(dam) == "number" then
	 dam = {dam=dam, dur=3, chance=25, fail = 50, perc=50}
      end
      if not dam.perc then
	 dam.perc = 50
      end
      local powerBonus = dam.power or 0
      local target = game.level.map(x, y, Map.ACTOR)

      --Static Damage
      if target then
	 rekWyrmicElectrocute(src, target)
      end
      
      local realdam = DamageType:get(DamageType.NATURE).projector(src, x, y, DamageType.NATURE, dam.dam* dam.perc / 100, state)
      
      if target then
	 if dam.drain and not src:attr("dead") then
	    src:heal(realdam * dam.drain, target)
	 end
      end
      if target and target:canBe("poison") then
	 if not rng.percent(dam.chance) then
	    dam.fail = 0
	 end
	 target:setEffect(target.EFF_REK_WYRMIC_VENOM, dam.dur,
			  {src=src,
			   power=(dam.dam * (125 - dam.perc) / 100) / dam.dur,
			   crippling=dam.fail,
			   criptime=3,
			   apply_power=src:combatMindpower(1, nil, 0), no_ct_effect=true})
      end
      return realdam
   end,
}

-- Accuracy/Power Down, doesn't show in the log.
newDamageType{
   name = "corrosive acid", type = "REK_SILENT_CORRODE",
   hideMessage=true,
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      if _G.type(dam) == "number" then dam = {dur = 4, dam = dam, atk=dam/2} end
      local target = game.level.map(x, y, Map.ACTOR)
      if target then
	 --DamageType:get(DamageType.ACID).projector(src, x, y, DamageType.ACID, dam.dam, state)
	 target:setEffect(target.EFF_REK_WYRMIC_CORRODE, dam.dur, {atk=dam.atk, apply_power=src:combatMindpower()})
      end
   end,
}

-- Silently marks enemy with vulnerability to your weapon attacks
newDamageType{
   name = "vulnerable energy", type = "REK_SILENT_ELEMENT_EXPLOIT",
   hideMessage=true,
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      local target = game.level.map(x, y, Map.ACTOR)
      if target then
	 target:setEffect(target.EFF_REK_WYRMIC_ELEMENT_EXPLOIT, 1, {})
      end
   end,
}

-- Half now, half over 4 turns, and circle-of-death status
newDamageType{
   name = "doom", type = "REK_WYRMIC_DARK",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      if _G.type(dam) == "number" then
	 dam = {dam=dam, chance=25, dur=3}
      end
      
      local target = game.level.map(x, y, Map.ACTOR)

      --Static Damage
      if target then
	 rekWyrmicElectrocute(src, target)
      end

      local dur = 3
      
      local realdam = DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam.dam, state)
      if target then
	 if dam.drain and not src:attr("dead") then
	    src:heal(realdam * dam.drain, target)
	 end
	 if rng.percent(dam.chance) then
            target:setEffect(target.EFF_REK_WYRMIC_DOOM, dur, { healFactorChange=-0.75, totalDuration=3 })
         end
      end
      return realdam      
   end,
}

-- Blight and chance to disease
newDamageType{
   name = "scourge blight", type = "REK_CORRUPTED_BLOOD", text_color = "#DARK_GREEN#",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      if _G.type(dam) == "number" then
	 dam = {dam=dam, chance=25, dur=3}
      end
      
      local target = game.level.map(x, y, Map.ACTOR)

      --Static Damage
      if target then
	 rekWyrmicElectrocute(src, target)
      end

      local disease_str = src:combatScale(src:combatSpellpower(), 10, 10, 20, 100)
      local dur = 3
      
      local realdam = DamageType:get(DamageType.BLIGHT).projector(src, x, y, DamageType.BLIGHT, dam.dam, state)
      if target then
	 if dam.drain and not src:attr("dead") then
	    src:heal(realdam * dam.drain, target)
	 end
	 if target:canBe("disease") and rng.percent(dam.chance) then
            local eff = rng.table{{target.EFF_ROTTING_DISEASE, "con"}, {target.EFF_DECREPITUDE_DISEASE, "dex"}, {target.EFF_WEAKNESS_DISEASE, "str"}}
            target:setEffect(eff[1], dur or 5, { src = src, [eff[2]] = disease_str, dam = dam.dam/10 })
         end
      end
      return realdam      
   end,
}


newDamageType
{
   name = "dissolution", type = "REK_WYRMIC_ACID_SLOW",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      local target = game.level.map(x, y, Map.ACTOR)
      if target then
	 target:setEffect(target.EFF_REK_WYRMIC_SLOW_MOVE, 4, {power=dam/100, apply_power=src:combatMindpower()})
      end
   end,
}


-- Shock, no damage
newDamageType{
   name = "electric shock", type = "REK_WYRMIC_SHOCK",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      local target = game.level.map(x, y, Map.ACTOR)
      state = initState(state)
      if target and not state[target] then
	 state[target] = true
	 target:setEffect(target.EFF_SHOCKED, 3, {apply_power=src:combatMindpower()})
      end
   end,
}

-- light with random spell/mind debuffs
newDamageType{
	name = "sparkling mist", type = "LUCKY_FAE_STATUS_LIGHT",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		
		if _G.type(dam) == "number" then
			dam = {dam=dam}
		end

		local luck = src:getLck() - 50
		local luckiness = 1
		if luck ~= 0 then	
			local negative = false
			if (luck < 0) then
				negative = true
				luck = -luck
			end
			
			local luck_mult = (luck/50) ^ .5
			
			if not negative then
				luckiness = 1 + luck_mult
			else
				luckiness = 1/(1+luck_mult)
			end
		end
			
		local chance = 30 * luckiness
		
		local target = game.level.map(x, y, Map.ACTOR)
		if target and not state[target] then
			local debuffs = {
				{'EFF_STUNNED', {}, 'stun'},
				{'EFF_PINNED', {}, 'pin'},
				{'EFF_SILENCED', {}, 'silence'},
				{'EFF_DISARMED', {}, 'disarm'},
				{'EFF_BLINDED', {}, 'blind'},
				{'EFF_CONFUSED', {power=50}, 'confuse'},
			}
			state[target] = true

			for i = 1, #debuffs do
				if rng.percent(chance) then
					if debuffs[i][3] and target:canBe(debuffs[i][3]) or not debuffs[i][3] then
						local args = table.clone(debuffs[i][2])
						args.apply_power=math.max(src:combatMindpower(), src:combatSpellpower())
						args.no_ct_effect = true
						target:setEffect(debuffs[i][1], 3, args)
					end
				end
			end
			
			if target then
				rekWyrmicElectrocute(src, target)
			end

			local dam_applied = dam.dam
			if src.getCaprice and src:getCaprice() >= 40 then
				dam_applied = dam_applied * 2
			end
			
			local realdam = DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam_applied, state)
			return realdam
			
		end
	end,
}
