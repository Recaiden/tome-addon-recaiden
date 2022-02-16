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

local base_atEnd = _M.atEnd
function _M:atEnd(v)
	if v == "created" and not self.ui_by_ui[self.c_ok].hidden then
		self.actor_base:learnTalent(self.actor_base.T_REK_COMBO_ONE, true)
		self.actor_base:learnTalent(self.actor_base.T_REK_COMBO_TWO, true)
		self.actor_base:learnTalent(self.actor_base.T_REK_COMBO_THREE, true)
		self.actor_base:learnTalent(self.actor_base.T_REK_COMBO_FOUR, true)
		self.actor_base:learnTalent(self.actor_base.T_REK_COMBO_FIVE, true)
		self.actor_base:learnTalent(self.actor_base.T_REK_COMBO_MANAGE, true)
	end
	return base_atEnd(self, v)
end

return _M
