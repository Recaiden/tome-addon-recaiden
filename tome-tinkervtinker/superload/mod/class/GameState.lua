require "engine.class"
require "engine.Entity"
local Map = require "engine.Map"

local _M = loadPrevious(...)

local base_applyRandomClassNew = _M.applyRandomClassNew
function _M:applyRandomClassNew(b, data, instant)
	if not game.state.birth.merge_tinkers_data then
		b.not_power_source = b.not_power_source or {}
		b.not_power_source["steam"] = true
	end
	return base_applyRandomClassNew(self, b, data, instant)
end


local base_applyRandomClass = _M.applyRandomClass
function _M:applyRandomClass(b, data, instant)
	if not game.state.birth.merge_tinkers_data then
		b.not_power_source = b.not_power_source or {}
		b.not_power_source["steam"] = true
	end
	return base_applyRandomClass(self, b, data, instant)
end

return _M
