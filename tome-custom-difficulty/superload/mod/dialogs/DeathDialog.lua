local Birther = require "engine.Birther"
local Game = require "engine.Game"

local _M = loadPrevious(...)

local base_generateList = _M.generateList
function _M:generateList()
   base_generateList(self)
   local list = self.list or {}
	 local size = #list
	 -- for j=1, #list, 1 do
	 -- 	 if list[j] and list[j].subaction == "restart" then
	 -- 		 for i=j, size, 1 do
	 -- 			 list[i] = list[i+1]
	 -- 		 end
	 -- 	 end
	 -- end
   
   self.list = list
   for _, item in ipairs(list) do self.possible_items[item.action] = true end
end

return _M
