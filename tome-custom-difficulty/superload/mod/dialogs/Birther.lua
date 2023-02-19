require "engine.class"
local Dialog = require "engine.ui.Dialog"
local Birther = require "engine.Birther"
local List = require "engine.ui.List"
local TreeList = require "engine.ui.TreeList"
local Button = require "engine.ui.Button"
local Dropdown = require "engine.ui.Dropdown"
local Textbox = require "engine.ui.Textbox"
local Checkbox = require "engine.ui.Checkbox"
local Textzone = require "engine.ui.Textzone"
local NumberSlider = require "engine.ui.NumberSlider"
local ImageList = require "engine.ui.ImageList"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"
local NameGenerator = require "engine.NameGenerator"
local NameGenerator2 = require "engine.NameGenerator2"
local Savefile = require "engine.Savefile"
local Module = require "engine.Module"
local Tiles = require "engine.Tiles"
local Particles = require "engine.Particles"
local CharacterVaultSave = require "engine.CharacterVaultSave"
local Object = require "mod.class.Object"
local OptionTree = require "mod.dialogs.OptionTree"

local Actor = require "mod.class.Actor"
local Talents = require "engine.interface.ActorTalents"

local _M = loadPrevious(...)

standardDifficulties = {
	["Easy"] = {
		zone_mul = "1.0", zone_add = "0",
		talent = "0", talent_boss = "1.0",
		randrare = 4, randboss = 0,
		stairwait = "2",
		health = "1.0",
		hunted = false, ezstatus = true,
		start_level = "1", start_life = "0", start_gold = "0",
	},
	["Normal"] = {
		zone_mul = "1.0", zone_add = "0",
		talent = "0", talent_boss = "1.0",
		randrare = 4, randboss = 0,
		stairwait = "2",
		health = "1.0",
		hunted = false, ezstatus = false,
		start_level = "1", start_life = "0", start_gold = "0",
	},
	["Nightmare"] = {
		zone_mul = "1.25", zone_add = "0",
		talent = "30", talent_boss = "1.3",
		randrare = 12.5, randboss = 0,
		stairwait = "3",
		health = "1.0",
		hunted = false, ezstatus = false,
		start_level = "1", start_life = "0", start_gold = "0",
	},
	["Insane"] = {
		zone_mul = "1.5", zone_add = "1",
		talent = "70", talent_boss = "1.7",
		randrare = 33.3, randboss = 5,
		stairwait = "5",
		health = "1.0",
		hunted = false, ezstatus = false,
		start_level = "1", start_life = "0", start_gold = "0",
	},
	["Madness"] = {
		zone_mul = "2.5", zone_add = "2",
		talent = "170", talent_boss = "2.7",
		randrare = 33.3, randboss = 5,
		stairwait = "9",
		health = "3.0",
		hunted = true, ezstatus = false,
		start_level = "1", start_life = "100", start_gold = "500",
	}
}

function _M:passesStandardDifficulty(name)
	local preset = standardDifficulties[name] or standardDifficulties["Normal"]
	if not self.c_rek_dif_zone_mul then return true end

	if (tonumber(self.c_rek_dif_zone_mul.text) or 1) < tonumber(preset.zone_mul) then
		print("[BIRTHER] [CNFG] zone mul too low for ", name)
		return false end
	if (tonumber(self.c_rek_dif_zone_add.text) or 1) < tonumber(preset.zone_add) then
		print("[BIRTHER] [CNFG] zone add too low for ", name)
		return false end
	if (tonumber(self.c_rek_dif_talent.text) or 1) < tonumber(preset.talent) then
		print("[BIRTHER] [CNFG] talent fail for ", name)
		return false end
	if self.c_rek_dif_randrare.value < preset.randrare then
		print("[BIRTHER] [CNFG] randrare for ", name)
		return false end
	if self.c_rek_dif_randboss.value < preset.randboss then
		print("[BIRTHER] [CNFG] randboss for ", name)
		return false end
	if (tonumber(self.c_rek_dif_health.text) or 1) < tonumber(preset.health) then
		print("[BIRTHER] [CNFG] life mult for ", name)
		return false end
	if (tonumber(self.c_rek_dif_stairwait.text) or 1) < tonumber(preset.stairwait) then
		print("[BIRTHER] [CNFG] stairwait for ", name)
		return false end
	if preset.hunted and not self.c_rek_dif_hunted.checked then
		print("[BIRTHER] [CNFG] hunted for ", name)
		return false end
	if self.c_rek_dif_ezstatus.checked and not preset.ezstatus then
		print("[BIRTHER] [CNFG] checked for ", name)
		return false end
	if (tonumber(self.c_rek_dif_life_bonus.text) or 0) > tonumber(preset.start_life) then
		print("[BIRTHER] [CNFG] excess life for ", name)
		return false end
	if (tonumber(self.c_rek_dif_gold.text) or 0) > tonumber(preset.start_gold) then
		print("[BIRTHER] [CNFG] excess gold for ", name)
		return false end
	if (tonumber(self.c_rek_dif_level.text) or 0) > tonumber(preset.start_level) then
		print("[BIRTHER] [CNFG] excess level for ", name)
		return false end
	return true
end

function updateDifficulties(self)   
   --local d = {}
   local d = self.birth_descriptor_def.difficulty["Custom"]
   local copy = {}
   local state = {}

   -- Player is always instakill immune
   copy["instakill_immune"] = 1
   -- Setup money and level
   copy["money"] = tonumber(self.c_rek_dif_gold.text) or 0
   copy["max_life_bonus"] = tonumber(self.c_rek_dif_life_bonus.text) or 0
   copy["start_level"] = tonumber(self.c_rek_dif_level.text) or 1

   -- Set random spawn rates if applicable
   local randrare = self.c_rek_dif_randrare.value
   local randboss = self.c_rek_dif_randboss.value

   --TODO, Unique vs Boss is handled in the boss generation routine
   -- currently hardcoded to 30%
   if randboss > 0 then
      state["default_random_boss_chance"] = math.floor(100 / randboss)
   end
   --Limitations
   if randboss + randrare > 100 then
      randrare = 100-randboss
   end
   if randrare > 0 then
      state["default_random_rare_chance"] = math.floor(100 / randrare)
   end

   -- Copy data to game_state object
   if tonumber(self.c_rek_dif_bossscale.text) then
      state["fixedboss_class_level_rate_mult"] = tonumber(self.c_rek_dif_bossscale.text)
   else
      state["fixedboss_class_level_rate_mult"] = 1
   end
   if tonumber(self.c_rek_dif_zone_mul.text) then
      state["difficulty_level_mult"] = tonumber(self.c_rek_dif_zone_mul.text)
   end
   if tonumber(self.c_rek_dif_zone_add.text) then
      state["difficulty_level_add"] = tonumber(self.c_rek_dif_zone_add.text)
   end
   if tonumber(self.c_rek_dif_health.text) then
      state["difficulty_life_mult"] = tonumber(self.c_rek_dif_health.text)
   end
   if tonumber(self.c_rek_dif_talent.text) then
      state["difficulty_talent_mult"] = 1+tonumber(self.c_rek_dif_talent.text)/100
   end
         
   --Hunted talent
   if self.c_rek_dif_hunted.checked then
      --local tal = {
--	 [ActorTalents.T_HUNTED_PLAYER] = 1,
      --}
      for talent, rank in pairs(d.rek_dif_talents_backup) do
	 d.talents[talent] = rank
      end
   elseif d.talents then
      for talent, rank in pairs(d.talents) do
	 d.talents[talent] = nil
      end
      --d.talents = tal
   end

   -- Copy things to the copy so they can move into the game object
   if tonumber(self.c_rek_dif_stairwait.text) then
      copy["rek_dif_stairwait"] = tonumber(self.c_rek_dif_stairwait.text)
   else
      copy["rek_dif_stairwait"] = 2
   end
   

   --Checkboxes
   if self.c_rek_dif_ezstatus.checked then
      copy["rek_dif_ezstatus"] = true
   end
   
   -- Determine difficulty for achievements
   if self:passesStandardDifficulty("Madness") then
      copy["__game_difficulty"] = 5
      d["name"] = "Madness" 
   elseif self:passesStandardDifficulty("Insane") then
      copy["__game_difficulty"] = 4
      d["name"] = "Insane"
   elseif self:passesStandardDifficulty("Nightmare") then
      copy["__game_difficulty"] = 3
      d["name"] = "Nightmare" 
   elseif self:passesStandardDifficulty("Normal") then
      copy["__game_difficulty"] = 2
      d["name"] = "Normal"
	 else
		 copy["__game_difficulty"] = 1.5 --don't set to 1 because then rares disappear whoops
		 d["name"] = "Easy"
   end

   d.copy = copy
   d.game_state = state
   self.birth_descriptor_def.difficulty["Custom"] = d
   self:setDescriptor("difficulty", "Custom")
end

function numberSliderSetValue(box, value)
	box.nbox.number = value
	box.nbox:updateText(0)
	box:onChange()
end

function setToStandardDifficulty(self, name)
	local preset = standardDifficulties[name] or standardDifficulties["Normal"]
	self.c_rek_dif_zone_mul:setText(preset.zone_mul or "1.0")
	self.c_rek_dif_zone_add:setText(preset.zone_add or "0")
	self.c_rek_dif_talent:setText(preset.talent or "0")
	numberSliderSetValue(self.c_rek_dif_randrare, preset.randrare or 4)
	numberSliderSetValue(self.c_rek_dif_randboss, preset.randboss or 0)
	self.c_rek_dif_bossscale:setText(preset.talent_boss or "0")
	self.c_rek_dif_stairwait:setText(preset.stairwait or "2")
	self.c_rek_dif_health:setText(preset.health or "1.0")
	self.c_rek_dif_hunted.checked = preset.hunted or false
	self.c_rek_dif_ezstatus.checked = preset.ezstatus or false
	self.c_rek_dif_level:setText(preset.start_level or "1")
	self.c_rek_dif_life_bonus:setText(preset.start_life or "0")
	self.c_rek_dif_gold:setText(preset.start_gold or "0")
	updateDifficulties(self)
end

local function setConfigStr(option, value)
	config.settings.tome.rek_dif = config.settings.tome.rek_dif or {}
	config.settings.tome.rek_dif[option] = value
	game:saveSettings("tome.rek_dif."..option, ("tome.rek_dif."..option.." = \"%s\"\n"):format(value))
end

local function setConfigNum(option, value)
	config.settings.tome.rek_dif = config.settings.tome.rek_dif or {}
	config.settings.tome.rek_dif[option] = value
	game:saveSettings("tome.rek_dif."..option, ("tome.rek_dif."..option.." = %d\n"):format(value))
end

-- save to secret configs
function _M:saveDifficulty()
	config.settings.tome.rek_dif = {
		zone_mul = self.c_rek_dif_zone_mul.text,
		zone_add = self.c_rek_dif_zone_add.text,
		talent = self.c_rek_dif_talent.text,
		randrare = self.c_rek_dif_randrare.value,
		randboss = self.c_rek_dif_randboss.value,
		talent_boss = self.c_rek_dif_bossscale.text,
		stairwait = self.c_rek_dif_stairwait.text,
		health = self.c_rek_dif_health.text,
		hunted = self.c_rek_dif_hunted.checked,
		ezstatus = self.c_rek_dif_ezstatus.checked,
		start_level = self.c_rek_dif_level.text,
		start_life = self.c_rek_dif_life_bonus.text,
		start_gold = self.c_rek_dif_gold.text,
	}
	game:saveSettings("tome.rek_dif", ([[tome.rek_dif = {}
tome.rek_dif.zone_mul = "%s"
tome.rek_dif.zone_add = "%s"
tome.rek_dif.talent = "%s"
tome.rek_dif.randrare = %0.2f
tome.rek_dif.randboss = %0.2f
tome.rek_dif.talent_boss = "%s"
tome.rek_dif.stairwait = "%s"
tome.rek_dif.health = "%s"
tome.rek_dif.hunted = %s
tome.rek_dif.ezstatus = %s
tome.rek_dif.start_level = "%s"
tome.rek_dif.start_life = "%s"
tome.rek_dif.start_gold = "%s"
]]):format(self.c_rek_dif_zone_mul.text,
					 self.c_rek_dif_zone_add.text,
					 self.c_rek_dif_talent.text,
					 self.c_rek_dif_randrare.value,
					 self.c_rek_dif_randboss.value,
					 self.c_rek_dif_bossscale.text,
					 self.c_rek_dif_stairwait.text,
					 self.c_rek_dif_health.text,
					 self.c_rek_dif_hunted.checked,
					 self.c_rek_dif_ezstatus.checked,
					 self.c_rek_dif_level.text,
					 self.c_rek_dif_life_bonus.text,
					 self.c_rek_dif_gold.text
	))
end

local function getConfig(str)
	if config.settings.tome.rek_dif then return config.settings.tome.rek_dif[str] end
	return nil
end

function _M:loadSavedDifficulty()
	self.c_rek_dif_zone_mul:setText(getConfig("zone_mul") or "1.0")
	self.c_rek_dif_zone_add:setText(getConfig("zone_add") or "0")
	self.c_rek_dif_talent:setText(getConfig("talent") or "0")
	numberSliderSetValue(self.c_rek_dif_randrare, getConfig("randrare") or 4)
	numberSliderSetValue(self.c_rek_dif_randboss, getConfig("randboss") or 0)
	self.c_rek_dif_bossscale:setText(getConfig("talent_boss") or "0")
	self.c_rek_dif_stairwait:setText(getConfig("stairwait") or "2")
	self.c_rek_dif_health:setText(getConfig("health") or "1.0")
	self.c_rek_dif_hunted.checked = getConfig("hunted") or false
	self.c_rek_dif_ezstatus.checked = getConfig("ezstatus") or false
	self.c_rek_dif_level:setText(getConfig("start_level") or "1")
	self.c_rek_dif_life_bonus:setText(getConfig("start_life") or "0")
	self.c_rek_dif_gold:setText(getConfig("start_gold") or "0")
end

function _M:init(title, actor, order, at_end, quickbirth, w, h)
   self.quickbirth = quickbirth
   self.actor = actor:cloneFull()
   self.actor_base = actor
   self.order = order
   self.at_end = at_end
   self.selected_cosmetic_unlocks = {}
   self.tiles = Tiles.new(64, 64, nil, nil, true, nil)
   
   Dialog.init(self, title and title or "Character Creation", math.max(w or 600, 1100), math.max(h or 400, 700))
   
   self.obj_list = Object:loadList("/data/general/objects/objects.lua")
   self.obj_list_by_name = {}
   for i, e in ipairs(self.obj_list) do
      if e.name and (e.rarity or e.define_as) then
	 self.obj_list_by_name[e.name] = e
      end
   end
   
   self.descriptors = {}
   self.descriptors_by_type = {}

   self.to_reset_cosmetic = {}

   
   self.c_ok = Button.new{text="     Play!     ",
			  fct=function()
			     updateDifficulties(self)
			     for i, d in ipairs(self.descriptors) do
				print("[BIRTHER]", i, d, d.name)
				-- for j, e in pairs(d) do
				--    print(j, e)
				-- end
			     end
					 self:saveDifficulty()
			     self:atEnd("created")
			  end
   }
   self.c_random = Button.new{text="Random!", fct=function() self:randomBirth() end}
   self.c_premade = Button.new{text="Load premade", fct=function() self:loadPremadeUI() end}
   self.c_tile = Button.new{text="Select custom tile", fct=function() self:selectTile() end}
   self.c_cancel = Button.new{text="Cancel", fct=function() self:atEnd("quit") end}
   self.c_tut = Button.new{text="Tutorial", fct=function() self:tutorial() end}
   self.c_options = Button.new{text="Customize", fct=function() self:customizeOptions() end}
   self.c_options.hide = true
   self.c_extra_options = Button.new{text="Extra Options", fct=function() self:extraOptions() end}

   self.c_extra_options.hide = not game.extra_birth_option_defs or #game.extra_birth_option_defs == 0
   
   self.c_name = Textbox.new{title="Name: ", text=(not config.settings.cheat and game.player_name == "player") and "" or game.player_name, chars=30, max_len=50, fct=function()
				if config.settings.cheat then self:makeDefault() end
   end, on_change=function() self:setDescriptor() end, on_mouse = function(button) if button == "right" then self:randomName() end end}
   
   self.c_female = Checkbox.new{title="Female", default=true,
				fct=function() end,
				on_change=function(s) self.c_male.checked = not s self:setDescriptor("sex", s and "Female" or "Male") end
   }
   self.c_male = Checkbox.new{title="Male", default=false,
			      fct=function() end,
			      on_change=function(s) self.c_female.checked = not s self:setDescriptor("sex", s and "Male" or "Female") end
   }

   --Custom Difficuly UI elements
   self.c_rek_dif_zone_mul = Textbox.new{
      title="Enemy Level Multiplier: ", text="1.0",
      chars=5, max_len=10,
      fct=function() end, on_change=function(s) updateDifficulties(self) end, on_mouse = function(button) end
   }
   self.c_rek_dif_zone_add = Textbox.new{
      title="Enemy Level Boost: ", text="0", chars=3, max_len=5,
      fct=function() end, on_change=function(s) updateDifficulties(self) end, on_mouse = function(button) end
   }
   self.c_rek_dif_talent = Textbox.new{
      title="Enemy Talent Bonus: ", text="0", chars=4, max_len=6,
      fct=function() end, on_change=function(s) updateDifficulties(self) end, on_mouse = function(button) end
   }

   self.c_rek_dif_bossscale = Textbox.new{
      title="Fixed Boss Scaling: ", text="1.0", chars=7, max_len=10,
      fct=function() end, on_change=function(s) updateDifficulties(self) end, on_mouse = function(button) end
   }
   
   self.c_rek_dif_randrare = NumberSlider.new{
      title="Rare %:", value=4, min=0, max=100, w=400, step=2,
      fct=function() end
   }
   self.c_rek_dif_randboss = NumberSlider.new{
      title="Boss %:", value=0, min=0, max=100, w=400, step=2,
      fct=function() end
   }
   self.c_rek_dif_stairwait = Textbox.new{
      title="Stair Delay: ", text="2", chars=4, max_len=5,
      fct=function() end, on_change=function(s) updateDifficulties(self) end, on_mouse = function(button) end
   }
   self.c_rek_dif_health = Textbox.new{
      title="Enemy Life Multiplier: ", text="1.0", chars=7, max_len=10,
      fct=function() end, on_change=function(s) updateDifficulties(self) end, on_mouse = function(button) end
   }
   self.c_rek_dif_level = Textbox.new{
      title="Player Starting Level: ", text="1", chars=4, max_len=4,
      fct=function() end, on_change=function(s) updateDifficulties(self) end, on_mouse = function(button) end
   }
   self.c_rek_dif_gold = Textbox.new{
      title="Player Starting Gold: ", text="0", chars=7, max_len=10,
      fct=function() end, on_change=function(s) updateDifficulties(self) end, on_mouse = function(button) end
                                    }
   self.c_rek_dif_life_bonus = Textbox.new{
      title="Player Bonus Life: ", text="0", chars=7, max_len=10,
      fct=function() end, on_change=function(s) updateDifficulties(self) end, on_mouse = function(button) end
   }
   self.c_rek_dif_hunted = Checkbox.new{title="Hunted", default=false, fct=function() end, on_change=function(s) updateDifficulties(self) end}
   self.c_rek_dif_ezstatus = Checkbox.new{title="Debuff Resistance", default=false, fct=function() end, on_change=function(s) updateDifficulties(self) end}
   --
   
   self:generateCampaigns()
   self.c_campaign_text = Textzone.new{auto_width=true, auto_height=true, text="Campaign: "}
   self.c_campaign = Dropdown.new{width=400, fct=function(item) self:campaignUse(item) end, on_select=function(item) self:updateDesc(item) end, list=self.all_campaigns, nb_items=#self.all_campaigns}

   -- permadeath
   self:generatePermadeaths()
   self.c_permadeath_text = Textzone.new{auto_width=true, auto_height=true, text="Permadeath: "}
   self.c_permadeath = Dropdown.new{width=150, fct=function(item) self:permadeathUse(item) end, on_select=function(item) self:updateDesc(item) end, list=self.all_permadeaths, nb_items=#self.all_permadeaths}

   -- preset difficulty selector
   self.c_diff_preset_easy = Button.new{text="Easy", fct=function() setToStandardDifficulty(self, "Easy") end}
   self.c_diff_preset_norm = Button.new{text="Normal", fct=function() setToStandardDifficulty(self, "Normal") end}
   self.c_diff_preset_nite = Button.new{text="Nightmare", fct=function() setToStandardDifficulty(self, "Nightmare") end}
   self.c_diff_preset_insn = Button.new{text="Insane", fct=function() setToStandardDifficulty(self, "Insane") end}
   self.c_diff_preset_madn = Button.new{text="Madness", fct=function() setToStandardDifficulty(self, "Madness") end}

   
   self.c_desc = TextzoneList.new{width=math.floor(self.iw / 4 - 15), height=self.ih - self.c_female.h - self.c_permadeath.h - self.c_ok.h - self.c_campaign.h - 10, scrollbar=true, pingpong=20, no_color_bleed=true}
   
   self:setDescriptor("base", "base")
   self:setDescriptor("world", self.default_campaign)
   --self:setDescriptor("difficulty", self.default_difficulty)
   updateDifficulties(self)
   self:setDescriptor("permadeath", self.default_permadeath)
   self:setDescriptor("sex", "Female")
   
   self:generateRaces()
   self.c_race = TreeList.new{width=math.floor(self.iw / 4 - 15), height=self.ih - self.c_female.h - self.c_permadeath.h - self.c_ok.h - (self.c_extra_options.hide and 0 or self.c_extra_options.h) - self.c_campaign.h - 10, scrollbar=true, columns={
   				 {width=100, display_prop="name"},
   }, tree=self.all_races,
   			      fct=function(item, sel, v) self:raceUse(item, sel, v) end,
   			      select=function(item, sel) self:updateDesc(item) end,
   			      on_expand=function(item) end,
   			      --on_drawitem=function(item) end,
   			     }
   
   self:generateClasses()
   self.c_class = TreeList.new{
      width=math.floor(self.iw / 4 - 15),
      height=self.ih - self.c_female.h - self.c_permadeath.h - self.c_ok.h - self.c_campaign.h - 10,
      scrollbar=true,
      columns={
	 {width=100, display_prop="name"},
      },
      tree=self.all_classes,
      fct=function(item, sel, v) self:classUse(item, sel, v) end,
      select=function(item, sel) self:updateDesc(item) end,
      on_expand=function(item) end,
      --on_drawitem=function(item) return 0 end,
   }
   
   self.cur_order = 1
   self.sel = 1
   
   self:loadUI{
      -- First line
      {left=0, top=0, ui=self.c_name},
      {left=self.c_name, top=0, ui=self.c_female},
      {left=self.c_female, top=0, ui=self.c_male},
      
      -- Second line
      {left=0, top=self.c_name, ui=self.c_campaign_text},
      {left=self.c_campaign_text, top=self.c_name, ui=self.c_campaign},
      
      -- Third line
      {left=0, top=self.c_campaign, ui=self.c_permadeath_text},
      {left=self.c_permadeath_text, top=self.c_campaign, ui=self.c_permadeath},
      {right=0, top=self.c_name, ui=self.c_tut},
      
      -- -- Lists
      {left=0, top=self.c_permadeath, ui=self.c_race},
      {left=self.c_race, top=self.c_permadeath, ui=self.c_class},
      
      --List of fields/boxes for difficulty
      {left=self.c_class, top=self.c_campaign, ui=self.c_diff_preset_easy},
      {left=self.c_diff_preset_easy, top=self.c_campaign, ui=self.c_diff_preset_norm},
      {left=self.c_diff_preset_norm, top=self.c_campaign, ui=self.c_diff_preset_nite},
      {left=self.c_diff_preset_nite, top=self.c_campaign, ui=self.c_diff_preset_insn},
      {left=self.c_diff_preset_insn, top=self.c_campaign, ui=self.c_diff_preset_madn},
                
      {left=self.c_class, top=self.c_diff_preset_madn, ui=self.c_rek_dif_zone_mul},
      {left=self.c_class, top=self.c_rek_dif_zone_mul, ui=self.c_rek_dif_zone_add},
      {left=self.c_class, top=self.c_rek_dif_zone_add, ui=self.c_rek_dif_talent},
      {left=self.c_class, top=self.c_rek_dif_talent, ui=self.c_rek_dif_randrare},
      {left=self.c_class, top=self.c_rek_dif_randrare, ui=self.c_rek_dif_randboss},
      {left=self.c_class, top=self.c_rek_dif_randboss, ui=self.c_rek_dif_bossscale},
      {left=self.c_class, top=self.c_rek_dif_bossscale, ui=self.c_rek_dif_stairwait},
      {left=self.c_class, top=self.c_rek_dif_stairwait, ui=self.c_rek_dif_health},
      {left=self.c_class, top=self.c_rek_dif_health, ui=self.c_rek_dif_hunted},
      {left=self.c_class, top=self.c_rek_dif_hunted, ui=self.c_rek_dif_ezstatus},
      {left=self.c_class, top=self.c_rek_dif_ezstatus, ui=self.c_rek_dif_level},
      {left=self.c_class, top=self.c_rek_dif_level, ui=self.c_rek_dif_life_bonus},
      {left=self.c_class, top=self.c_rek_dif_life_bonus, ui=self.c_rek_dif_gold},
      --
      
      {right=0, top=self.c_diff_preset_madn, ui=self.c_desc},
      
      -- Buttons
      {left=0, bottom=0, ui=self.c_ok, hidden=true},
      {left=self.c_ok, bottom=0, ui=self.c_random},
      {left=self.c_random, bottom=0, ui=self.c_premade},
      {left=self.c_premade, bottom=0, ui=self.c_tile},
      {left=self.c_tile, bottom=0, ui=self.c_options},
      {right=0, bottom=0, ui=self.c_cancel},
      
      {left=0, bottom=self.c_ok, ui=self.c_extra_options},
   }
   self:setupUI()
   
   if self.descriptors_by_type.difficulty == "Tutorial" then
      self:permadeathUse(self.all_permadeaths[1], 1)
      self:raceUse(self.all_races[1], 1)
      self:raceUse(self.all_races[1].nodes[1], 2)
      self:classUse(self.all_classes[1], 1)
      self:classUse(self.all_classes[1].nodes[1], 2)
   end
   for i, item in ipairs(self.c_campaign.c_list.list) do
      if self.default_campaign == item.id then
	 self.c_campaign.c_list.sel = i break
      end
   end
   for i, item in ipairs(self.c_permadeath.c_list.list) do
      if self.default_permadeath == item.id then
	 self.c_permadeath.c_list.sel = i break
      end
   end
   if config.settings.tome.default_birth and config.settings.tome.default_birth.sex then
      self.c_female.checked = config.settings.tome.default_birth.sex == "Female"
      self.c_male.checked = config.settings.tome.default_birth.sex ~= "Female"
      self:setDescriptor("sex", self.c_female.checked and "Female" or "Male")
   end
	 self:loadSavedDifficulty()
   self:setFocus(self.c_campaign)
   self:setFocus(self.c_name)
   
   if not profile.mod.allow_build.tutorial_done then
      self:setFocus(self.c_tut)
      self.c_tut.glow = 0.70
   end
end

function _M:on_focus(id, ui)
   if self.focus_ui and self.focus_ui.ui == self.c_name then
      self.c_desc:switchItem(self.c_name, "This is the name of your character.\nRight mouse click to generate a random name based on race and sex.")      
   elseif self.focus_ui and self.focus_ui.ui == self.c_female then
      self.c_desc:switchItem(self.c_female, self.birth_descriptor_def.sex.Female.desc)
   elseif self.focus_ui and self.focus_ui.ui == self.c_male then
      self.c_desc:switchItem(self.c_male, self.birth_descriptor_def.sex.Male.desc)
   elseif self.focus_ui and self.focus_ui.ui == self.c_campaign then
      local item = self.c_campaign.c_list.list[self.c_campaign.c_list.sel]
      self.c_desc:switchItem(item, item.desc)
   elseif self.focus_ui and self.focus_ui.ui == self.c_permadeath then
      local item = self.c_permadeath.c_list.list[self.c_permadeath.c_list.sel]
      self.c_desc:switchItem(item, item.desc)
   -- Focus Descriptions for new difficulty options
   elseif self.focus_ui and self.focus_ui.ui == self.c_rek_dif_zone_mul then
      self.c_desc:switchItem(self.c_rek_dif_zone_mul, "Multiply the level of all zones by this amount.\nNightmare: 1.25 or higher\nInsane: 1.5 or higher\nMadness: 2.5 or higher")
   elseif self.focus_ui and self.focus_ui.ui == self.c_rek_dif_zone_add then
      self.c_desc:switchItem(self.c_rek_dif_zone_add, "Increase the level of all enemies by this amount.\nInsane: 1 or more\nMadness: 2 or more")
   elseif self.focus_ui and self.focus_ui.ui == self.c_rek_dif_talent then
      self.c_desc:switchItem(self.c_rek_dif_talent, "Increase the level of all enemy talents by this percentage.\nNightmare: 30+\nInsane: 70+\nMadness: 170+")
      
   elseif self.focus_ui and self.focus_ui.ui == self.c_rek_dif_randrare then
      self.c_desc:switchItem(self.c_rek_dif_randrare, "The percentage of random enemies that will spawn with higher rank and extra talents.\nNightmare: 12.5 or higher\nInsane: 33.3 or higher")
   elseif self.focus_ui and self.focus_ui.ui == self.c_rek_dif_randboss then
      self.c_desc:switchItem(self.c_rek_dif_randboss, "The percentage of random enemies that will spawn as bosses, in addition to the boss of each zone.\nBosses have additional talents and immunities and greatly increased health and attributes.\nInsane: 5+")
      
   elseif self.focus_ui and self.focus_ui.ui == self.c_rek_dif_stairwait then
      self.c_desc:switchItem(self.c_rek_dif_stairwait, "The number of turns you need to wait after a kill before you can use stairs.\n2+ for Normal\n3+ for Nightmare\n5+ for Insane\n9+ for Madness")
   elseif self.focus_ui and self.focus_ui.ui == self.c_rek_dif_health then
      self.c_desc:switchItem(self.c_rek_dif_health, "Multiply the health of all enemies by this amount.\nMadness: 3.0 or higher")
   elseif self.focus_ui and self.focus_ui.ui == self.c_rek_dif_bossscale then
      self.c_desc:switchItem(self.c_rek_dif_bossscale, "Increase the talents given to fixed bosses.\nNightmare: 1.3+\nInsane: 1.7+\nMadness: 2.7+")
   elseif self.focus_ui and self.focus_ui.ui == self.c_rek_dif_hunted then
      self.c_desc:switchItem(self.c_rek_dif_hunted, "Enemies will randomly discover where the player is located.\nIt is needed to qualify for Madness")
   elseif self.focus_ui and self.focus_ui.ui == self.c_rek_dif_ezstatus then
      self.c_desc:switchItem(self.c_rek_dif_ezstatus, "Using this will halve the duration of detrimental statuses applied to the player.\nUsing it disqualifies you from achievements")
   elseif self.focus_ui and self.focus_ui.ui == self.c_rek_dif_level then
      self.c_desc:switchItem(self.c_rek_dif_level, "The level the player starts at.\nRaising it disqualifies you from achievements")
   elseif self.focus_ui and self.focus_ui.ui == self.c_rek_dif_life_bonus then
      self.c_desc:switchItem(self.c_rek_dif_life_bonus, "Starts the player with additional maximum life.\nRaising it disqualifies you from achievements unless you also qualify for Madness (which gives 100)")
   elseif self.focus_ui and self.focus_ui.ui == self.c_rek_dif_gold then
      self.c_desc:switchItem(self.c_rek_dif_gold, "The gold the player starts with.\nRaising it disqualifies you from achievements unless you also qualify for Madness (which gives 500)")
   end
end

return _M
