local _M = loadPrevious(...)
local base_combatMovementSpeed = _M.combatMovementSpeed

--- Makes you move faster on Frozen Path
function _M:combatMovementSpeed(x, y)

   -- execute the original function
   local retval = base_combatMovementSpeed(self, x, y)
   
   local mult = 1
   if game.level and game.level.data.zero_gravity then
      mult = 3
   end

   local movement_speed = mult * (self.base_movement_speed or 1) / retval

   if x and y and game.level.map:checkAllEntities(x, y, "glacialPath") and self:knowTalent(self.T_WANDER_ICE_CONE) then
      local t = self:getTalentFromId(self.T_WANDER_ICE_CONE)
      movement_speed = movement_speed + t.getMovementSpeedChange(self, t)
   end 
   movement_speed = math.max(movement_speed, 0.1)
   return mult * (self.base_movement_speed or 1) / movement_speed
end

function _M:combatSpellpowerRaw(add)
	if self.combat_precomputed_spellpower then return self.combat_precomputed_spellpower, 1 end
	add = add or 0

	if self.combat_generic_power then
		add = add + self.combat_generic_power
	end
	if self:knowTalent(self.T_ARCANE_CUNNING) then
		add = add + self:callTalent(self.T_ARCANE_CUNNING,"getSpellpower") * self:getCun() / 100
	end
	if self:knowTalent(self.T_SHADOW_CUNNING) then
		add = add + self:callTalent(self.T_SHADOW_CUNNING,"getSpellpower") * self:getCun() / 100
	end
	if self:knowTalent(self.T_LUNACY) then
		add = add + self:callTalent(self.T_LUNACY,"getSpellpower") * self:getWil() / 100
	end
	if self:hasEffect(self.EFF_BLOODLUST) then
		add = add + self:hasEffect(self.EFF_BLOODLUST).spellpower * self:hasEffect(self.EFF_BLOODLUST).stacks
	end
	if self.summoner and self.summoner:knowTalent(self.summoner.T_BLIGHTED_SUMMONING) then
		add = add + self.summoner:getMag()
	end

	local am = 1
	if self:attr("spellpower_reduction") then am = 1 / (1 + self:attr("spellpower_reduction")) end

	local d = math.max(0, (self.combat_spellpower or 0) + add + self:getMag())
	if self:attr("dazed") then d = d / 2 end
	if self:attr("scoured") then d = d / 1.2 end

	if self:attr("hit_penalty_2h") then d = d * (1 - math.max(0, 20 - (self.size_category - 4) * 5) / 100) end

	return d, am
end

return _M
