local _M = loadPrevious(...)
local base_on_set_temporary_effect = _M.on_set_temporary_effect

function _M:on_set_temporary_effect(eff_id, e, p)
   -- execute the original function
   local retval = base_on_set_temporary_effect(self, eff_id, e, p)

   -- Apply easy-mode bonus
   if game.difficulty ~= game.DIFFICULTY_EASY and game.rek_dif_easy_effects and self.player and e.status == "detrimental" then
      p.dur = math.ceil(p.dur / 2)
   end

	 return retval
end

return _M

