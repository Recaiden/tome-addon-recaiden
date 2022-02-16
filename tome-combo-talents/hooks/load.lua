local Birther = require "engine.Birther"
local Talents = require "engine.interface.ActorTalents"

class:bindHook(
	"ToME:load",
	function(self, data)
		Talents:loadDefinition('/data-combo-talents/talents.lua')
end)
