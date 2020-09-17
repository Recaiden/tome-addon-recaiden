local DamageType = require "engine.DamageType"

local _M = loadPrevious(...)

local base_bumpInto = _M.bumpInto
function _M:bumpInto(target)
	local reaction = self:reactionToward(target)
	if reaction < 0 and self:isTalentActive(self.T_REK_DEML_ENGINE_FULL_THROTTLE) then
		local dam = self:callTalent(self.T_REK_DEML_ENGINE_FULL_THROTTLE, "getDamage")
		DamageType:get(DamageType.PHYSICAL).projector(self, target.x, target.y, DamageType.PHYSICAL, dam)
		local dx = target.x - self.x
		local dy = target.y - self.y
		if not game.level.map:checkAllEntities(self.x+dx*2, self.y+dy*2, "block_move", self) then
			self:move(self.x+dx*2, self.y+dy*2, true)
			if self:isTalentActive(self.T_REK_DEML_ENGINE_BLAZING_TRAIL) then
				local damageFlame = self:callTalent(self.T_REK_DEML_ENGINE_BLAZING_TRAIL, "getDamage")
				game.level.map:addEffect(self, target.x, target.y, 4, engine.DamageType.FIRE, damageFlame, 0, 5, nil, {type="inferno"}, nil, true)
			end
		end
		local energy = game.energy_to_act * self:combatMovementSpeed(x, y)
		self:useEnergy(energy)
		self.did_energy = true
	else return base_bumpInto(self, target) end
end

return _M
