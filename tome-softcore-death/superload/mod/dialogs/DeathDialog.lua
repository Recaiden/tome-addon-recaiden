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
			
			self.actor:attr("easy_mode_lifes", -1)
			local nb = self.actor:attr("easy_mode_lifes") and self.actor:attr("easy_mode_lifes") or 0
			local style
			if(nb > 0) then style = ("#LIGHT_RED#You have %d life(s) left."):tformat(nb)
			else style = ("#LIGHT_RED#You have no more lives left."):tformat() end
			game.log(style)
			
			local is_exploration = game.permadeath == game.PERMADEATH_INFINITE
			self:cleanActor(self.actor)
			self:resurrectBasic(self.actor, "eidolon_plane")
			for e, _ in pairs(game.party.members) do if e ~= self.actor then
					self:cleanActor(e)
			end end
			for uid, e in pairs(game.level.entities) do
				if not is_exploration or game.party:hasMember(e) then
					self:restoreResources(e)
				end
			end

			game.party:goToEidolon(self.actor)

			game.log("#LIGHT_RED#From the brink of death you seem to be yanked to another plane.")
			game.player:updateMainShader()
			if not config.settings.cheat then game:onTickEnd(function() game:saveGame() end) end
			
			self.actor:checkTwoHandedPenalty()
   elseif act == "drop_to_explore" then
		 self.actor:attr("infinite_lifes", 1)
		 game.permadeath = game.PERMADEATH_INFINITE
		 
		 local is_exploration = game.permadeath == game.PERMADEATH_INFINITE
		 self:cleanActor(self.actor)
		 self:resurrectBasic(self.actor, "eidolon_plane")
		 for e, _ in pairs(game.party.members) do if e ~= self.actor then
				 self:cleanActor(e)
		 end end
		 for uid, e in pairs(game.level.entities) do
			 if not is_exploration or game.party:hasMember(e) then
				 self:restoreResources(e)
			 end
		 end
		 
		 game.party:goToEidolon(self.actor)
		 
		 game.log("#LIGHT_RED#From the brink of death you seem to be yanked to another plane.")
		 game.player:updateMainShader()
		 if not config.settings.cheat then game:onTickEnd(function() game:saveGame() end) end
		 
		 self.actor:checkTwoHandedPenalty()
   else
      return base_use(self, item)
   end
end

local base_generateList = _M.generateList
function _M:generateList()
   base_generateList(self)
   local list = self.list or {}

   if game.permadeath ~= game.PERMADEATH_INFINITE and profile:isDonator(1) then
      for i=#list,1,-1 do
         list[i+1] = list[i]
      end
      list[1] = {name="Beg the Eidolon to save you (Go to Exploration mode)", action="drop_to_explore"}
   end
   if game.permadeath == game.PERMADEATH_ONE then
      for i=#list,1,-1 do
         list[i+1] = list[i]
      end
      list[1] = {name="Call on the Eidolon to save you (Go to Adventure mode)", action="drop_to_adventure"}
   end
   
   self.list = list
   for _, item in ipairs(list) do self.possible_items[item.action] = true end
end

return _M
