require "engine.class"
local Chat = require "engine.Chat"
local Dialog = require "engine.ui.Dialog"


local _M = loadPrevious(...)

local base_setInscription = _M.setInscription

function _M:setInscription(id, name, data, cooldown, vocal, src, bypass_max_same, bypass_max)
   local oldRestriction = nil
   if self.inscription_forbids then
      oldRestriction = self.inscription_forbids["inscriptions/infusions"]
   end

   local tn = self:getTalentFromId(self["T_"..name.."_1"])
   if self:knowTalent(self.T_REK_WIGHT_DODGE) and tn.type[1] == "inscriptions/infusions" then
      local countInfusions = 0
      local infusionName = ""
      local infusionTitle = ""
      for i = 1, self.max_inscriptions do
         if self.inscriptions[i] then
            local t = self:getTalentFromId(self["T_"..self.inscriptions[i]])
            if t.type[1] == "inscriptions/infusions" then
               countInfusions = countInfusions + 1
               infusionName = string.gsub(string.upper(t.name), " ", "_")
               infusionTitle = t.name
            end
         end
      end

      -- first infusion, allowed
      if countInfusions == 0 then
         self.inscription_forbids["inscriptions/infusions"] = nil
      -- second infusion, can only replace first infusion
      elseif countInfusions == 1 then
         self.inscription_forbids["inscriptions/infusions"] = nil
         if not bypass_max_same then
            if vocal then game.logPlayer(self, "You already have an infusion.") end
            -- Replace chat
            if self.player and src then
               src.player = self
               src.iname = name
               src.idata = data
               src.replace_same = infusionName
               local chat = Chat.new("player-inscription", {name=infusionTitle}, self, src)
               chat:invoke()
            end
            
            return
         end
      end
   end
         
   local ret = base_setInscription(self, id, name, data, cooldown, vocal, src, bypass_max_same, bypass_max)
   if oldRestriction then
      self.inscription_forbids["inscriptions/infusions"] = oldRestriction
   end

   return ret
end

return _M
