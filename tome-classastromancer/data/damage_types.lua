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

-- Increased cold damage + freeze chance if wet, doesn't hit allies
newDamageType{
	name = "glacial vapor", type = "LUXAM_VAPOUR", text_color = "#1133F3#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local chance = 0
		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:hasEffect(target.EFF_WET) then
			dam = dam * 1.3 chance = 15
		end
		if target and src:reactionToward(target) < 0 then
			local realdam = DamageType:get(DamageType.COLD).projector(src, x, y, DamageType.COLD, dam, state)
			if rng.percent(chance) then
				DamageType:get(DamageType.FREEZE).projector(src, x, y, DamageType.FREEZE, {dur=2, hp=70+dam*1.2}, state)
			end
		end
		return realdam
	end,
}

-- Cold damage + freeze chance, increased if wet, doesn't hit allies
newDamageType{
	name = "glacial storm", type = "LUXAM_ICE_STORM", text_color = "#1133F3#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local chance = 25

		local target = game.level.map(x, y, Map.ACTOR)
		if target and target:hasEffect(target.EFF_WET) then dam = dam * 1.3 chance = 50 end

		local realdam = 0
		if target and src:reactionToward(target) < 0 then
			realdam = DamageType:get(DamageType.COLD).projector(src, x, y, DamageType.COLD, dam, state)
			if rng.percent(chance) then
				DamageType:get(DamageType.FREEZE).projector(src, x, y, DamageType.FREEZE, {dur=2, hp=70+dam*1.5}, state)
			end
		end
		return realdam
	end,
}


-- fire that lowers resists
newDamageType{
	name = "volcanic rift", type = "WANDER_FIRE_CRUSH",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then
			dam = {dam=dam, dur=3, power=20}
		end
		
		local target = game.level.map(x, y, Map.ACTOR)
		if not target or target.dead then return end
		
		if target and src:reactionToward(target) < 0 then
			DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam.dam, state)
			if not target:attr("fly")
				and not target:attr("levitation")
			then
				target:setEffect(target.EFF_WANDER_FISSURE_AMP, dam.dur, {power=dam.power, apply_power=src:combatSpellpower()})
			end	 
		end
	end,
}

-- Cold damage + speed reduction (no wet or freeze)
newDamageType{
   name = "rime", type = "LUXAM_COLD_SLOW",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      local target = game.level.map(x, y, Map.ACTOR)
      if target then
				DamageType:get(DamageType.COLD).projector(src, x, y, DamageType.COLD, dam, state)
				target:setEffect(target.EFF_SLOW, 3, {power=0.2, apply_power=src:combatSpellpower()})
      end
   end,
}

-- Cold damage +speed reduction +speed allies +wet (but no freeze chance)
newDamageType{
	name = "glacial cold", type = "LUXAM_COLD",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if src:reactionToward(target) >= 0 then
				target:setEffect(target.EFF_WANDER_INVIGORATING_CHILL, dam.dur, {power=dam.speed, src=src})
			else
				DamageType:get(DamageType.COLD).projector(src, x, y, DamageType.COLD, dam.dam, state)
				target:setEffect(target.EFF_SLOW, dam.dur, {power=dam.speed, apply_power=src:combatSpellpower(), src=src})
				target:setEffect(target.EFF_WET, 5, {})
      end
		end
	end,
}

-- lightning damage to enemies, healing to allies
newDamageType{
	name = "bright lightning", type = "GOOD_LIGHTNING",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if src:reactionToward(target) >= 0 then
				-- include your lightning increase as a bonus
				if src.combatGetDamageIncrease then
					local bonus = src:combatGetDamageIncrease(DamageType.LIGHTNING) / 100
					if bonus > 0 then dam.dam = dam.dam * (1 + bonus) end
				end
				if dam.heal then dam.dam = dam.dam * dam.heal end
				DamageType:get(DamageType.HEAL).projector(src, x, y, DamageType.HEAL, dam.dam, state)
			elseif src:reactionToward(target) < 0 then
				DamageType:get(DamageType.LIGHTNING).projector(src, x, y, DamageType.LIGHTNING, dam.dam, state)
			end
		end
	end,
}

-- fire and blind
newDamageType{
	name = "meteor flash", type = "METEOR_BLIND", text_color = "#ORANGE#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		
		local target = game.level.map(x, y, Map.ACTOR)
		if not target or target.dead then return end
		
		if target then
			DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam, state)
			-- try to blind
			if target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, 2, {apply_power=src:combatSpellpower()})
			end
		end
	end,
}

-- instant fire and stun (not flameshock)
newDamageType{
	name = "meteor blast", type = "METEOR_BLAST", text_color = "#ORANGE#",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		
		local target = game.level.map(x, y, Map.ACTOR)
		if not target or target.dead then return end
		
		if target then
			DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam, state)
			-- try to stun
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 4, {apply_power=src:combatSpellpower()})
			end
		end
	end,
}

newDamageType{
   name = "manaworm arcane", type = "ASTROMANCER_MANAWORM",
   projector = function(src, x, y, type, dam, state)
      state = initState(state)
      useImplicitCrit(src, state)
      local realdam = DamageType:get(DamageType.ARCANE).projector(src, x, y, DamageType.ARCANE, dam, state)
      local target = game.level.map(x, y, Map.ACTOR)
      if target then
         if game.zone.void_blast_hits and game.party:hasMember(target) then game.zone.void_blast_hits = game.zone.void_blast_hits + 1 end
         
         if target:knowTalent(target.T_MANA_POOL) then
            target:setEffect(target.EFF_MANAWORM, 5, {power=dam * 5, src=src, no_ct_effect=true})
            src:die()
         else
            game.logSeen(target, "%s has no mana to burn.", target.name:capitalize())
         end
      end
      return realdam
   end,
}