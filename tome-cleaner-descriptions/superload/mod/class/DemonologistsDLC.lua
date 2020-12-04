_M = loadPrevious(...)
module(..., package.seeall, class.make)
local DamageType = require "engine.DamageType"

function hookObjectDescWielder(self, data)
	data.compare_fields(data.w, data.compare_with, data.field, "artifact_power_obsidian", "%+d", self.mod_align_stat("Shadow Power"))
end

return _M