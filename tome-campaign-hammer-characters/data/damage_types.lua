local useImplicitCrit = DamageType.useImplicitCrit
local initState = DamageType.initState

newDamageType{
	name = _t("blindness", "damage type"), type = "BLIND_ALLPOWER",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			if target:canBe("blind") then
				target:setEffect(target.EFF_BLINDED, math.ceil(dam), {apply_power=src:combatBestpower()})
			end
		end
	end,
}

newDamageType{
	name = _t("shadowflame", "damage type"), type = "SHADOWFLAME_FRIENDS",
	projector = function(src, x, y, type, dam, state)
		state = initState(state)
		useImplicitCrit(src, state)
		local target = game.level.map(x, y, Map.ACTOR)
		if target and src:reactionToward(target) < 0 then
			DamageType:get(DamageType.FIRE).projector(src, x, y, DamageType.FIRE, dam / 2, state)
			DamageType:get(DamageType.DARKNESS).projector(src, x, y, DamageType.DARKNESS, dam / 2, state)
		end
	end,
}
