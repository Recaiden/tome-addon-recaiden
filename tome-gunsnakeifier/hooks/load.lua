local class = require"engine.class"
local Birther = require "engine.Birther"

class:bindHook("ToME:load", function(self, data)
  Birther:loadDefinition("/data-gunsnakeifier/birth/classes/tinker.lua")
end)
