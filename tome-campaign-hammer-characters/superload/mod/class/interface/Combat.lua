local _M = loadPrevious(...)
require "engine.class"
local DamageType = require "engine.DamageType"
local Map = require "engine.Map"
local Chat = require "engine.Chat"
local Target = require "engine.Target"
local Talents = require "engine.interface.ActorTalents"

_M:addCombatTraining("unarmed", "T_REK_IMP_ETERNAL_FLAME")

_M.hasDualTwoHand = function(self) -- 
	local oh_weaps = table.clone(self:getInven(self.INVEN_OFFHAND)) or {}
	local mh_weaps = table.clone(self:getInven(self.INVEN_MAINHAND)) or {}
	local off = oh_weaps and oh_weaps[1] or false
	local main = mh_weaps and mh_weaps[1] or false
	if not main or not off then return false end

	return main, off
end

return _M
