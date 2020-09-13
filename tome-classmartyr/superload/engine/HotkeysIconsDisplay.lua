local _M = loadPrevious(...)

require "engine.class"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Tiles = require "engine.Tiles"
local UI = require "engine.ui.Base"

--- Display of hotkeys with icons
-- @classmod engine.HotkeysIconsDisplay
module(..., package.seeall, class.make)

local base_display = _M.display

-- Displays the hotkeys, keybinds & cooldowns
function _M:display()
	local a = self.actor
	if not a or not a.changed then return self.surface end

	if a.getInsanity then
		for tid, talent in pairs(a.talents_def) do	
			if talent.display_entity_sane then
				if a:getInsanity() <= 40 then
					a.talents_def[tid].display_entity = talent.display_entity_sane
				elseif a:getInsanity() < 60 then
					a.talents_def[tid].display_entity = talent.display_entity_semisane
				else
					a.talents_def[tid].display_entity = talent.display_entity_insane
				end
			end
		end
	end
	base_display(self)
end

return _M