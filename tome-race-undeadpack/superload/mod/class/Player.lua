local _M = loadPrevious(...)

local base_playerFOV = _M.playerFOV
function _M:playerFOV()
   base_playerFOV(self)
   
   if self:knowTalent(self.T_REK_DREAD_SUMMON_DREAD) then    
      for dread, _ in pairs(game.party.members) do
         if dread.is_dreadlord_minion and not dread.dead and dread.x then
            game.level.map:apply(dread.x, dread.y, 0.6)
            game.level.map:applyExtraLite(dread.x, dread.y)
         end   
      end
   end
end

return _M
