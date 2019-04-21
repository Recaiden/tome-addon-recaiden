require "engine.class"
local Dialog = require "engine.ui.Dialog"
local Textzone = require "engine.ui.Textzone"
local TextzoneList = require "engine.ui.TextzoneList"
local ActorFrame = require "engine.ui.ActorFrame"
local List = require "engine.ui.List"
local Button = require "engine.ui.Button"
local DamageType = require "engine.DamageType"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor, possibles)
   self.actor = actor
   self.possibles = possibles
   self.max_aspects = actor:callTalent(actor.T_REK_WYRMIC_MULTICOLOR_BLOOD, "getNumAspects")
   self.rek_wyrmic_dragon_type = {}
   
   Dialog.init(self, ("Prismatic Aspects: Select up to %d elements"):format(self.max_aspects) , 680, 500)
   
   self:generateList()
   
   self.c_ok = Button.new{text="Accept", fct=function() self:ok() end}
   self.c_cancel = Button.new{text="Cancel", fct=function() self:cancel() end}
   self.c_list = List.new{scrollbar=true, width=680, height=self.ih - 5 - self.c_ok.h,
			  list=self.list,
			  fct=function(item)
			     self:use(item)
			  end,
			  select=function(item)
			     self:select(item)
			  end
   }
   --local help = Textzone.new{width=math.floor(self.iw - self.c_list.w - 20), height=self.ih, no_color_bleed=true, auto_height=true, text="#SLATE##{italic}# Help would go here."}
   --self.c_desc = TextzoneList.new{scrollbar=true, width=help.w, height=self.ih - help.h - 40 - self.c_cancel.h}
   
   self:loadUI{
      {left=0, top=0, ui=self.c_list},
      --{right=0, top=0, ui=help},
      --{right=0, top=help, ui=self.c_desc},
      {left=0, bottom=0, ui=self.c_ok},
      {right=0, bottom=0, ui=self.c_cancel},
   }
   self:setupUI(false, false)
   
   self.key:addBinds{
      EXIT = function()
	 self:cancel()
      end,
   }
   
   self:select(self.list[1])
end


function _M:use(item)
   if not item then return end
   item.used = not item.used
   item.color = item.used and colors.simple(colors.LIGHT_GREEN) or colors.simple(colors.LIGHT_RED)
   self.c_list:drawItem(item)
   
   table.removeFromList(self.rek_wyrmic_dragon_type, item)
   
   if item.used then
      table.insert(self.rek_wyrmic_dragon_type, item)
   end
   
   self.c_ok.hide = self.max_aspects < #self.rek_wyrmic_dragon_type
end

function _M:select(item)
--   if not item or not self.c_desc then return end
--   self.c_desc:switchItem(item.desc, item.desc)
end

function _M:cancel()
   game:unregisterDialog(self)
end

function _M:ok()
   if self.max_aspects >= #self.rek_wyrmic_dragon_type then
      -- Save list of aspects
      self.actor.rek_wyrmic_dragon_type = self.rek_wyrmic_dragon_type
      -- Set damage type if we're changing to a set that doesn't include it
      if #self.rek_wyrmic_dragon_type >= 1 then
	 local primary_old = self.actor.rek_wyrmic_dragon_damage
	 self.actor.rek_wyrmic_dragon_damage = self.rek_wyrmic_dragon_type[1]
	 if primary_old then
	    for i, v in ipairs(self.rek_wyrmic_dragon_type) do
	       if v == primary_old then
		  self.actor.rek_wyrmic_dragon_damage = primary_old
	       end
	    end
	 end
      else
	 self.actor.rek_wyrmic_dragon_damage = nil
      end
      -- Set status type if we're changing to a set that doesnt include it
      if #self.rek_wyrmic_dragon_type >= 2 then
	 local secondary_old = self.actor.rek_wyrmic_dragon_status
	 self.actor.rek_wyrmic_dragon_status = self.rek_wyrmic_dragon_type[2]
	 if secondary_old then
	    for i, v in ipairs(self.rek_wyrmic_dragon_type) do
	       if v == secondary_old then
		  self.actor.rek_wyrmic_dragon_status = secondary_old
	       end
	    end
	 end
      else
	 self.actor.rek_wyrmic_dragon_status = nil
      end
      game:unregisterDialog(self)
   end
end

function _M:generateList()
   local list = {}
   local remainingAspects = self.max_aspects
   
   for idx, aspect in pairs(self.possibles) do
      local d = {
	 name = aspect.name,
	 --aspect.nameDrake.." - "..aspect.name.." - "..aspect.nameStatus,
	 nameStatus = aspect.nameStatus,
	 nameDrake = aspect.nameDrake,
	 damtype=aspect.damtype,
	 status = aspect.status,
	 talent = aspect.talent,
	 color = colors.simple(colors.LIGHT_GREEN),
	 used = true,
	 desc = "..."
      }
      if remainingAspects <= 0 then
	 d.color = colors.simple(colors.LIGHT_RED)
	 d.used = false
      else
	 table.insert(self.rek_wyrmic_dragon_type, d)
      end
      list[#list+1] = d
      remainingAspects = remainingAspects - 1
   end
   
   self.list = list
end
