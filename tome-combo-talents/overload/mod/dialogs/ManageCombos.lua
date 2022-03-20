require "engine.class"
local Dialog = require "engine.ui.Dialog"
local TreeList = require "engine.ui.TreeList"
local ListColumns = require "engine.ui.ListColumns"
local Textzone = require "engine.ui.Textzone"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"

module(..., package.seeall, class.inherit(Dialog))
-- Could use better icons when available
local confirmMark = require("engine.Entity").new({image="ui/chat-icon.png"})
local autoMark = require("engine.Entity").new({image = "ui/hotkeys/mainmenu.png"})

function _M:init(actor)
	self.actor = actor
	actor.hotkey = actor.hotkey or {}
	Dialog.init(self, ("Manage Talent Combos"):tformat(), game.w * 0.8, game.h * 0.8)

	local vsep = Separator.new{dir="horizontal", size=self.ih - 10}
	-- explanation text at the top right
	self.c_tut = Textzone.new{width=math.floor(self.iw / 3 - vsep.w / 3), height=1, auto_height=true, no_color_bleed=true, text=_t[[
You can bind any number of talents to a combo, but a combo can contain at most one non-instant talent, which must be at the end.
You can drag talents onto the end of combos, or right-click a talent in the list to get a choice of combos to add it to.
Right-click a talent in a combo to remove it.
]]}

	-- description of the talent being hovered
	self.c_desc = TextzoneList.new{width=math.floor(self.iw / 3 - vsep.w / 3), height=self.ih - self.c_tut.h - 20, scrollbar=true, no_color_bleed=true}

	self:generateLists()

	-- list of talents
	local cols = {
		{name=_t"", width={40,"fixed"}, display_prop="char"},
		{name=_t"Talent", width=85, display_prop="name"}
	}
	self.c_list = TreeList.new{
		width=math.floor(self.iw / 3 - vsep.w / 3), height=self.ih - 10,
		all_clicks=true, scrollbar=true, columns=cols, tree=self.list,
		fct=function(item, sel, button) self:clickTalentList(item, button) end,
		select=function(item, sel) self:select(item) end,
		on_drag=function(item, sel) self:onDrag(item) end,
		on_drag_end=function(item, sel) self:draggedToList(item) end
	}
	self.c_list.cur_col = 2

	-- list of combos and talents in them
	local colsCombo = {
		{name=_t"", width={40,"fixed"}, display_prop="char"},
		{name=_t"Combo", width=80, display_prop="name"},
	}
	self.c_combos = ListColumns.new{
		width=math.floor(self.iw / 3 - vsep.w / 3), height=self.ih - 10,
		all_clicks = true, sortable=true, scrollbar=true, columns=colsCombo, list={},
		fct=function(item, sel, button) self:clickTalentCombo(item, button) end,
		select=function(item, sel) self:select(item) end,
		on_drag=function(item, sel) self:onDrag(item) end,
		on_drag_end=function(item, sel) self:draggedToCombo(item) end
	}
	self:generateComboList()

	self:loadUI{
		{ui=self.c_combos, left=0, top=0,},
		{left=self.c_combos.w, top=0, ui=self.c_list},
		{right=0, top=self.c_tut.h + 20, ui=self.c_desc},
		{right=0, top=0, ui=self.c_tut},
		--{ui=vsep, left=self.c_combos, top=5},
	}
	self:setFocus(self.c_list)
	self:setupUI()

	self.key:addCommands{
		__TEXTINPUT = function(c)
			if c == '~' then
				self:clickTalentList(self.cur_item, "right")
			end
			if self.list and self.list.chars[c] then
				self:clickTalentList(self.list.chars[c])
			end
		end,
	}
	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:on_register()
	game:onTickEnd(function() self.key:unicodeInput(true) end)
end

function _M:select(item)
	if item then
		self.c_desc:switchItem(item, item.desc)
		self.cur_item = item
	end
end


comboContainsActive = function(self, i)
	if not self.rec_combo or not self.rec_combo[i] then return false end
	local combo = self.rec_combo[i]
	for order, tid in ipairs(combo) do
		local t_sub = self:getTalentFromId(tid)
		if not util.getval(t_sub.no_energy, self, t_sub) then return true end
	end
	return false
end

comboContainsTalent = function(self, i, t)
	if not self.rec_combo or not self.rec_combo[i] then return false end
	local combo = self.rec_combo[i]
	for order, tid in ipairs(combo) do
		if tid == t then return true end
	end
	return false
end

--===========================================================================--
--                     Talent movement between categories                    --
--===========================================================================--
function _M:selectTalent(item, comboIdx)
	if not item or not item.talent then return end
	self.actor.rec_combo[comboIdx] = self.actor.rec_combo[comboIdx] or {}

	--check for other timed talent
	if comboContainsActive(self.actor, comboIdx) then return end

	if comboContainsTalent(self.actor, comboIdx, item.talent) then return end

	self.actor.rec_combo[comboIdx][#self.actor.rec_combo[comboIdx]+1] = item.talent
	self:generateComboList()
	self.actor:talentDialogReturn(true)
end

function _M:deselectTalent(item)
	if not item or not item.talent or not item.comboN or not item.comboIdx then return end
	self.actor.rec_combo[item.comboIdx][item.comboN] = nil
	local n = item.comboN + 1
	while self.actor.rec_combo[item.comboIdx][n] do
		self.actor.rec_combo[item.comboIdx][n-1] = self.actor.rec_combo[item.comboIdx][n]
		self.actor.rec_combo[item.comboIdx][n] = nil
		n = n+1
	end
	self:generateComboList()
	self.actor:talentDialogReturn(true)
end

--===========================================================================--
--                               Drag & Drop                                 --
--===========================================================================--
function _M:onDrag(item)
	if item and item.talent then
		if not self.dragged_item then self.dragged_item = item end
		local t = self.actor:getTalentFromId(item.talent)
		local s = t.display_entity:getEntityFinalSurface(nil, 64, 64)
		local x, y = core.mouse.get()
		game.mouse:startDrag(x, y, s, {kind="talent", id=t.id}, function(drag, used)
			local x, y = core.mouse.get()
			game.mouse:receiveMouse("drag-end", x, y, true, nil, {drag=drag})
			if drag.used then self.c_list:drawTree() end
		end)
	end
end

-- selection is the index within the list that the drag was on
function _M:draggedToCombo(destination)
	local item = self.dragged_item
	if not item or not item.talent then return end

	local idx = destination.comboIdx
	if item.comboN and item.comboIdx then --from one combo to another
		self:deselectTalent(item)
	end
	self:selectTalent(item, idx)
	self.dragged_item = nil
end

function _M:draggedToList(destination)
	local item = self.dragged_item
	if not item or not item.talent then return end
	if item.comboN and item.comboIdx then --drag out of combo and remove
		self:deselectTalent(item)
	end
	self.dragged_item = nil
end

--===========================================================================--
--                           Mouse Click Handlers                            --
--===========================================================================--
function _M:clickTalentCombo(item, button)
	if button == "right" then
		self:deselectTalent(item)
	end
end

function _M:clickTalentList(item, button)
	if not item or not item.talent then return end
	local t = self.actor:getTalentFromId(item.talent)
	if button == "right" then
		local list = {
			{name=_t"One", what=1},
			{name=_t"Two", what=2},
			{name=_t"Three", what=3},
			{name=_t"Four", what=4},
			{name=_t"Five", what=5},
		}
		Dialog:listPopup(("Move talent: %s"):tformat(item.name:toString()), _t"Add to which combo?", list, 400, 500, function(b)
			if not b then return end
			if type(b.what) ~= "number" then return end
			self:selectTalent(item, b.what)
		end)
	end
end

--===========================================================================--
--                                List Reading                               --
--===========================================================================--
function _M:generateTalentList()
	-- Makes up the list
	local list = {}
	local letter = 1
	
	local actives, sustains, objects, passives, instants = {}, {}, {}, {}, {}
	local chars = {}
	
	-- Generate lists of all talents by category
	for j, t in pairs(self.actor.talents_def) do
		if self.actor:knowTalent(t.id) and not t.innate and not (t.hide and t.mode == "passive") then
			local nodes = (t.mode == "sustained" and sustains) or (t.mode =="passive" and passives) or (t.is_object_use and objects) or (util.getval(t.no_energy, self.actor, t) and instants) or actives
			
			-- Pregenerate icon with the Tiles instance that allows images
			if t.display_entity then t.display_entity:getMapObjects(game.uiset.hotkeys_display_icons.tiles, {}, 1) end
			local tname = t.is_object_use and tostring(self.actor:getTalentDisplayName(t)) or t.name
			nodes[#nodes+1] = {
				name=((t.display_entity and t.display_entity:getDisplayString() or "")..tname):toTString(),
				cname=tname,
				entity=t.display_entity,
				talent=t.id,
				desc=self.actor:getTalentFullDescription(t),
				color=function() return {0xFF, 0xFF, 0xFF} end,
				hotkey=function(item)
					if t.mode == "passive" then return "" end
					for i = 1, 12 * self.actor.nb_hotkey_pages do
						if self.actor.hotkey[i] and self.actor.hotkey[i][1] == "talent" and self.actor.hotkey[i][2] == item.talent then
							return "H.Key "..i..""
						end
					end
					return ""
				end
			}
		end
	end

	table.sort(actives, function(a,b) return a.cname < b.cname end)
	table.sort(sustains, function(a,b) return a.cname < b.cname end)
	table.sort(instants, function(a,b) return a.cname < b.cname end)
	--table.sort(objects, function(a,b) return a.cname < b.cname end)
	for i, node in ipairs(instants) do node.char = self:makeKeyChar(letter) chars[node.char] = node letter = letter + 1 end
	for i, node in ipairs(actives) do node.char = self:makeKeyChar(letter) chars[node.char] = node letter = letter + 1 end
	for i, node in ipairs(sustains) do node.char = self:makeKeyChar(letter) chars[node.char] = node letter = letter + 1 end
	-- for i, node in ipairs(objects) do node.char = self:makeKeyChar(letter) chars[node.char] = node letter = letter + 1 end

	list = {
		{ char='', name=(_t'#{bold}#Instant talents#{normal}#'):toTString(), status='', hotkey='', desc=_t"All normal instant talents you know.", color=function() return colors.simple(colors.LIGHT_BLUE) end, nodes=instants, shown=true },
		{ char='', name=(_t'#{bold}#Activable talents#{normal}#'):toTString(), status='', hotkey='', desc=_t"All talents you know which take time to use.", color=function() return colors.simple(colors.LIGHT_GREEN) end, nodes=actives, shown=true },
		-- { char='', name=(_t'#{bold}#Object powers#{normal}#'):toTString(), status='', hotkey='', desc=_t"Object powers that can be activated automatically.  Most usable objects will appear here unless they are on cooldown or have ai restrictions.", color=function() return colors.simple(colors.SALMON) end, nodes=objects, shown=true },
		{ char='', name=(_t'#{bold}#Sustainable talents#{normal}#'):toTString(), status='', hotkey='', desc=_t"All sustainable talents you know.", color=function() return colors.simple(colors.YELLOW) end, nodes=sustains, shown=true },
		chars = chars
	}
	self.list = list
end

function _M:generateComboList()
	local list = {}

	self.actor.rec_combo = self.actor.rec_combo or {}
	local comboTalents = {}
	
	local comboCategories = {
		{ char='T_REK_COMBO_ONE', name=(_t'#{bold}#Combo One#{normal}#'):toTString(), desc=_t"A combo talent", color=colors.simple(colors.PURPLE), shown=true, comboIdx = 1 },
		{ char='T_REK_COMBO_TWO', name=(_t'#{bold}#Combo Two#{normal}#'):toTString(), desc=_t"A combo talent", color=colors.simple(colors.SALMON), shown=true, comboIdx = 2 },
		{ char='T_REK_COMBO_THREE', name=(_t'#{bold}#Combo Three#{normal}#'):toTString(), desc=_t"A combo talent", color=colors.simple(colors.LIGHT_GREEN), shown=true, comboIdx = 3 },
		{ char='T_REK_COMBO_FOUR', name=(_t'#{bold}#Combo Four#{normal}#'):toTString(), desc=_t"A combo talent", color=colors.simple(colors.YELLOW), shown=true, comboIdx = 4 },
		{ char='T_REK_COMBO_FIVE', name=(_t'#{bold}#Combo Five#{normal}#'):toTString(), desc=_t"A combo talent", color=colors.simple(colors.LIGHT_BLUE), shown=true, comboIdx = 5 }
	}
	for idx, header in ipairs(comboCategories) do
		local t = self.actor.talents_def[header.char]
		if t.display_entity then t.display_entity:getMapObjects(game.uiset.hotkeys_display_icons.tiles, {}, 1) end
		comboCategories[idx].char = ((t.display_entity and t.display_entity:getDisplayString() or "")):toTString()
	end

	-- remove talents you no longer know
	for idx, combo in pairs(self.actor.rec_combo) do
		comboTalents[idx] = {}
		for order, tid in ipairs(combo) do
			if not self.actor:knowTalent(tid) then
				self:deselectTalent({
					talent=tid,
					comboN = order,
					comboIdx = idx,
				})
			end
		end
	end
	
	-- Generate lists of all talents by category
	for idx, combo in pairs(self.actor.rec_combo) do
		comboTalents[idx] = {}
		for order, tid in ipairs(combo) do
			local t = self.actor:getTalentFromId(tid)
			if t then
				--get icon and name
				if t.display_entity then t.display_entity:getMapObjects(game.uiset.hotkeys_display_icons.tiles, {}, 1) end
				local tname = t.is_object_use and tostring(self.actor:getTalentDisplayName(t)) or t.name
				--construct list object
				comboTalents[idx][order] = {
					char = '',
					name=((t.display_entity and t.display_entity:getDisplayString() or "")..tname):toTString(),
					cname=tname,
					entity=t.display_entity,
					talent=t.id,
					comboN = order,
					comboIdx = idx,
					desc=self.actor:getTalentFullDescription(t),
					color={0xFF, 0xFF, 0xFF}
				}
			end
		end
	end

	for idx, header in ipairs(comboCategories) do
		list[#list+1] = header
		if comboTalents[idx] then
			for order, talentBlob in ipairs(comboTalents[idx]) do list[#list+1] = talentBlob end
		end
	end
	
	self.combo_list_ref = list
	if self.c_combos then self.c_combos:setList(list) end
end


function _M:generateLists()
	self:generateTalentList()
	self:generateComboList()
end
