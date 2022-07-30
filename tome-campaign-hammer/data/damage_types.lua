local initState = engine.DamageType.initState
local useImplicitCrit = engine.DamageType.useImplicitCrit

newDamageType{
	name = _t("% chance to stun", "damage type"), type = "REK_HAMMER_CHANCE_TO_STUN",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		if _G.type(dam) == "number" then dam = {dam=dam} end
		local target = game.level.map(x, y, Map.ACTOR)
		if target and rng.percent(dam.dam) then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 3, {power=dam.power or 30, apply_power=(dam.power_check or src.combatBestpower)(src), no_ct_effect=true})
			else
				game.logSeen(target, "%s resists!", target:getName():capitalize())
			end
		end
	end,
}
