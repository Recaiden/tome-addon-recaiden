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

return _M
