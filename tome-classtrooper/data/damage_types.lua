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
	name = "laser", type = "REK_CARBINE_LIGHT",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)

		-- deal damage
		local realdam = DamageType:get(DamageType.LIGHT).projector(src, x, y, DamageType.LIGHT, dam.dam, state)

		-- potential physical shrapnel damage
		-- if src and src.turn_procs and src.turn_procs.rek_oclt_dig then
		-- 	DamageType:get(DamageType.PHYSICAL).projector(src, x, y, DamageType.PHYSICAL, src.turn_procs.rek_oclt_dig, state)
		-- end

		if dam.blind then
			if target:canBe("blind") then
				local check = src:combatBestpower()
				target:setEffect(target.EFF_BLINDED, dam.blind, {apply_power=(check), no_ct_effect=true})
			else
				game.logSeen(target, "%s resists the blinding light!", target:getName():capitalize())
			end
		end

		if dam.vuln then
			if target:canBe("blind") then
				local check = src:combatBestpower()
				target:setEffect(target.EFF_BLINDED, dam.blnid, {apply_power=(check), no_ct_effect=true})
			else
				game.logSeen(target, "%s resists the blinding light!", target:getName():capitalize())
			end
		end
		
		return realdam
	end,
}

newDamageType{
	name = _t("dig", "damage type"), type = "EXPLOSIVE_DIG",
	projector = function(src, x, y, typ, dam)
		state = initState(state)
		useImplicitCrit(src, state)
		local feat = game.level.map(x, y, Map.TERRAIN)
		local target = game.level.map(x, y, Map.ACTOR)
		if feat then
			if feat.dig then
				local newfeat_name, newfeat, silence = feat.dig, nil, false
				if type(feat.dig) == "function" then newfeat_name, newfeat, silence = feat.dig(src, x, y, feat) end
				newfeat = newfeat or game.zone.grid_list[newfeat_name]
				if newfeat then
					game.level.map(x, y, Map.TERRAIN, newfeat)
					src.dug_times = (src.dug_times or 0) + 1
					if src.turn_procs then src.turn_procs.has_dug = (src.turn_procs.has_dug or 0) + 1 end
					game.nicer_tiles:updateAround(game.level, x, y)
					if not silence then
						game.logSeen({x=x,y=y}, "%s turns into %s.", _t(feat.name):capitalize(), _t(newfeat.name))
					end
					if src then
						local tg = {type="ball", range=10, radius=1, talent=t}
						game.level.map:particleEmitter(x, y, tg.radius, "ball_physical", {radius=tg.radius, tx=x, ty=y})
						src:project(tg, x, y, DamageType.PHYSICAL, src:occultCrit(dam))
					end
				end
			end
		end
		local hd = {"DamageProjector:dig", src=src, target=target, feat=feat, x=x, y=y, state=state}
		src:triggerHook(hd)
	end,
}
