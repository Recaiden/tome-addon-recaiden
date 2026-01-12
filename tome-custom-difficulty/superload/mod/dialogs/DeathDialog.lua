local Birther = require "engine.Birther"
local Game = require "engine.Game"

local _M = loadPrevious(...)

local base_use = _M.use
function _M:use(item)
   if not item then return end
   local act = item.action
   
   if act == "drop_to_adventure" then
      self.actor.easy_mode_lifes = 1
      if self.actor.level >= 2 then
         self.actor.easy_mode_lifes = self.actor.easy_mode_lifes + 1
      end
      if self.actor.level >= 5 then
         self.actor.easy_mode_lifes = self.actor.easy_mode_lifes + 1
      end
      if self.actor.level >= 7 then
         self.actor.easy_mode_lifes = self.actor.easy_mode_lifes + 1
      end
      if self.actor.level >= 14 then
         self.actor.easy_mode_lifes = self.actor.easy_mode_lifes + 1
      end
      if self.actor.level >= 24 then
         self.actor.easy_mode_lifes = self.actor.easy_mode_lifes + 1
      end
      if self.actor.level >= 35 then
         self.actor.easy_mode_lifes = self.actor.easy_mode_lifes + 1
      end
      game.permadeath = game.PERMADEATH_MANY
      self:eidolonPlane()
   elseif act == "drop_to_explore" then
      self.actor:attr("infinite_lifes", 1)
      game.permadeath = game.PERMADEATH_INFINITE
      self:eidolonPlane()
   else
      return base_use(self, item)
   end
end

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
