local engine = require "engine.class"
local Actor = require "engine.Actor"
local Map = require "engine.Map"
local ActorInventory = require "engine.interface.ActorInventory"

local _M = loadPrevious(...)

local base_getObjectOffslot = _M.getObjectOffslot
--- Returns the possible offslot
function _M:getObjectOffslot(o)
	local ret = base_getObjectOffslot(self, o)
	if o.slot == "MAINHAND" and o.slot_forbid == "OFFHAND" and self:attr("can_dual_2hand") then return "OFFHAND" end
	return ret
end

local base_slotForbidCheck = _M.slotForbidCheck
function _M:slotForbidCheck(o, in_inven_id)
	in_inven_id = self:getInven(in_inven_id).id
	local ret = base_slotForbidCheck(self, o, in_inven_id)
	if o.slot == "MAINHAND" and o.slot_forbid == "OFFHAND" and self:attr("can_dual_2hand") then
		return false
	end
	return ret
end

return _M
