local _M = loadPrevious(...)

local base_setupCommands = _M.setupCommands
function _M:setupCommands()
	base_setupCommands(self)

	local base_any_key = game.key.any_key
	game.key.any_key = function(sym, ctrl, shift, alt, meta, unicode, isup, key, ismouse)
    base_any_key(sym, ctrl, shift, alt, meta, unicode, isup, key, ismouse)
		if (sym == game.key._LALT) or (sym == game.key._RALT) then
			game.player.changed = true
			game.tooltip.old_tmx = nil
			
			-- Dodgy Hack(TM) by zizzo
			-- Pretend the ctrl_state has changed to trick Game:display() into updating the tooltip.
      game.ctrl_state = not core.key.modState('ctrl')
		end
	end
end

return _M
