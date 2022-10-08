local class = require"engine.class"
local Map = require "engine.Map"
local Dialog = require "engine.ui.Dialog"
local Tiles = require "engine.Tiles"

class:bindHook(
	"Entity:loadList",
	function(self, data)
		if type(game) ~= "table" then return end

		if data.file == "/data/zones/mark-spellblaze/grids.lua" then
			self:loadList("/data-alternate-merchants/marktile.lua", data.no_default, data.res, data.mod, data.loaded)
		end
	end
)
