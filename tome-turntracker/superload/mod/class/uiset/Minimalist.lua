local _M = loadPrevious(...)

local UI = require "engine.ui.Base"
local Dialog = require "engine.ui.Dialog"

shat = _M.shat

-- Copied from parent
local function imageLoader(file)
  local sfile = "/data/gfx/"..UI.ui.."-ui/minimalist/"..file
  if fs.exists(sfile) then
    return core.display.loadImage(sfile)
  else
    return core.display.loadImage( "/data/gfx/ui/"..file)
  end
end

local pf_bg_x, pf_bg_y = 0, 0
local pf_bg = {imageLoader("playerframe/back.png"):glTexture()}
local move_handle = {imageLoader("move_handle.png"):glTexture()}
local portrait = {imageLoader("party-portrait.png"):glTexture()}
local portrait_unsel = {imageLoader("party-portrait-unselect.png"):glTexture()}
local portrait_lev = {imageLoader("party-portrait-lev.png"):glTexture()}
local portrait_unsel_lev = {imageLoader("party-portrait-unselect-lev.png"):glTexture()}


-- sizing
local turntracker_w = 480
local turntracker_h = 80

local super_init = _M.init
function _M:init()
  super_init(self)

	self.turntracker = {}

  self.mhandle_pos.turntracker = {x=portrait[6] - move_handle[6], y=0, name = _t"Turn Tracker"}
  -- Our superloaded :resetPlaces() should have put .places.turntracker{} in
  -- place for us.  Our own .places{}, on the other hand, are in a separate
  -- location (otherwise the UI would choke on them if we disabled this
  -- addon), so we have to merge them into place ourself. 
  -- [cf. Spectacularly Dodgy Hack(TM) in the UISet:Minimalist:saveSettings hook]
  local d, ok = table.get(config.settings.tome, 'uiset_minimalist', 'addon', 'turntracker', 'places')
  if ok and d and self.places.turntracker then
    table.merge(self.places.turntracker, d, true)
  end
end

local super_resetPlaces = _M.resetPlaces
function _M:resetPlaces()
  super_resetPlaces(self)

	self.places.turntracker = {x=pf_bg[6], y=0, scale=1, a=1}
end

local lf16 = core.display.newFont("/data/font/DroidSans.ttf", 16, true)
lf16:setStyle("bold")
local lf12 = core.display.newFont("/data/font/DroidSans.ttf", 12, true)
lf12:setStyle("bold")
local lf10 = core.display.newFont("/data/font/DroidSans.ttf", 10, true)
lf10:setStyle("bold")
local TileSizeParams = {
	[64] = function() return lf16, 50, -20 end,
	[48] = function() return lf12, 38, -15 end,
	[32] = function() return lf12, 25, -15 end,
	[16] = function() return lf10, 10, -10 end
}

local super_display = _M.display
function _M:display(nb_keyframes)
  super_display(self, nb_keyframes)
  -- Don't do anything if we didn't draw the rest of the UI.
  if game.creating_player or self.no_ui then return end

  local d = core.display	-- Copied from parent
  local spwc = self.places.turntracker

  d.glTranslate(spwc.x, spwc.y, 0)
  d.glScale(spwc.scale, spwc.scale, spwc.scale)
  self:displayTurntracker(spwc.scale, spwc.x, spwc.y)
  d.glScale()
  d.glTranslate(-spwc.x, -spwc.y, 0)

	if not game or not game.zone or not game.player then return end
	if game.zone.wilderness then return end
	if not self.turntracker_highlight then return end

	local x, y = game.level.map:getTileToScreen(self.turntracker_highlight[1].x, self.turntracker_highlight[1].y)
	local fnParams = TileSizeParams[game.level.map.tile_w or 32] or TileSizeParams[32]
	local lf, deltax, deltay = fnParams()
	local sfun = function (lf, i) return {core.display.drawStringBlendedNewSurface(lf, self.turntracker_highlight[2], 81, 221, 255):glTexture()} end
	local s = sfun(lf, 1)
	s[1]:toScreenFull(x + deltax, y + deltay, s[6], s[7], s[2], s[3])
end

function _M:displayTurntracker(scale, bx, by)
	local player = game.player
	if not game.level then
		self.turntracker = {}
	elseif player.changed then
		for a, d in pairs(self.turntracker) do
			if not game.party:hasMember(a) and (not player:hasLOS(a.x, a.y) and player:canSee(a))
			then game.mouse:unregisterZone(d[2])
			end
		end
		self.turntracker = {}
		
		-- Calculate time till next turn based off global speed and energy
		local cutoff = 2.2 * game.energy_to_act / game.energy_per_tick
		local entities = {}
		local letter = 1
		if game.level then
			for uid, act in pairs(game.level.entities) do
				if game.party and (game.party:hasMember(act) or (player:hasLOS(act.x, act.y) and player:canSee(act))) and act.global_speed then
					
					-- assign each creature a letter tag
					act.turntracker_marker = letter <= 26 and string.char(letter+96) or "?"
					letter = letter + 1
					
					local thresh, tick = game.energy_to_act, game.energy_per_tick
					local eRemaining = thresh - act.energy.value
					local ticksRemaining = (eRemaining / 100) / act.global_speed
					entities[#entities+1] = {a=act, t=ticksRemaining}
					
					local first = true
					while ticksRemaining < cutoff do
						if first and act == player and self.turntracker_selected_tid then
							eRemaining = eRemaining + player:getTalentSpeed(player:getTalentFromId(self.turntracker_selected_tid)) * game.energy_to_act
							ticksRemaining = math.max(0, (eRemaining / 100) / act.global_speed)
							entities[#entities+1] = {a=act, t=ticksRemaining}
							first = false
						else
							eRemaining = eRemaining + game.energy_to_act
							ticksRemaining = math.max(0, (eRemaining / 100) / act.global_speed)
							entities[#entities+1] = {a=act, t=ticksRemaining}
						end
					end
				end
			end
		end
		table.sort(entities, function(a, b) return a.t < b.t end)
		-- cap list
		local count = #entities
		for i=11, count do entities[i]=nil end
		player.turn_tracker_entities = entities
	end
	-- Draw list	
	local orient = self.sizes.turntracker and self.sizes.turntracker.orient or "down"
	local hs = portrait[7] + 3
	local x, y = 0, 0
	local is_first = true

	local tooltip_drawn = {}
	local ents = player.turn_tracker_entities or {}
	for i = 1, #ents do
		local a = ents[i].a
		if not self.turntracker[a] then
			a.turntracker_ticks = ents[i].t
			
			local text = ("#GOLD##{bold}#%s\n#WHITE##{normal}#Life: %d%%\nMove  Speed: %d%%\nAttck Speed: %d%%\nSpell Speed: %d%%\nMind  Speed: %d%%"):tformat(a:getName(), math.floor(100 * a.life / a.max_life), 100/a:getSpeed("movement"), 100/a:getSpeed("weapon"), 100/a:getSpeed("spell"), 100/a:getSpeed("mind"))
			if a.summon_time then text = text..("\nTurns remaining: %s"):tformat(a.summon_time) end
			local is_first = (i == 1)
			local desc_fct = function(button, mx, my, xrel, yrel, bx, by, event)
				if event == "out" then
					self.turntracker_highlight = nil
				else
					self.turntracker_highlight = {a, a.turntracker_marker}
				end
				if is_first then
					if event == "out" then
						self.mhandle.turntracker = nil
						return
					else self.mhandle.turntracker = true end
					-- Move handle
					if not self.locked and bx >= self.mhandle_pos.turntracker.x and bx <= self.mhandle_pos.turntracker.x + move_handle[6] and by >= self.mhandle_pos.turntracker.y and by <= self.mhandle_pos.turntracker.y + move_handle[7] then
						self:uiMoveResize("turntracker", button, mx, my, xrel, yrel, bx, by, event)
						return
					end
				end
				
				game.tooltip_x, game.tooltip_y = 1, 1; game:tooltipDisplayAtMap(game.w, game.h, text)
			end

			local draw_fct = function(x, y, t)
				core.display.drawQuad(x, y, 40, 40, 0, 0, 0, 255)
				-- if marked then 
				-- 	core.display.drawQuad(x+1, y+1, 38, 38, 215, 190, 105, 178)
				-- end
				
				local scale, bx, by = self.places.turntracker.scale, self.places.turntracker.x, self.places.turntracker.y
				core.display.glScissor(true, bx+x*scale, by+y*scale, 40*scale, 40*scale)
				a:toScreen(nil, x+4, y+4, 32, 32)
				core.display.glScissor(false)
				
				local p = (game.player == a) and portrait or portrait_unsel -- highlight player
				p[1]:toScreenFull(x, y, p[6], p[7], p[2], p[3])
				
				-- Display ticks till turn over the portrait
				local gtxt = self.turntracker[a].txt_turntracker_ticks
				local txt = ("%0.1f"):format(t/10)
				local fw, fh = self.buff_font_smallmed:size(txt)
				self.turntracker[a].txt_turntracker_ticks = self.buff_font_smallmed:draw(txt, fw, colors.WHITE.r, colors.WHITE.g, colors.WHITE.b, true)[1]
				gtxt = self.turntracker[a].txt_turntracker_ticks
				gtxt.fw, gtxt.fh = fw, fh
				self.turntracker[a].cur_turntracker_ticks = a.turntracker_ticks
				if shader then
					shader:use(true)
					shader:uniOutlineSize(0.7, 0.7)
					shader:uniTextSize(gtxt._tex_w, gtxt._tex_h)
				else
					gtxt._tex:toScreenFull(x-gtxt.fw+36+1, y-2+1, gtxt.w, gtxt.h, gtxt._tex_w, gtxt._tex_h, 0, 0, 0, self.shadow or 0.6)
				end
				gtxt._tex:toScreenFull(x-gtxt.fw+36, y-2, gtxt.w, gtxt.h, gtxt._tex_w, gtxt._tex_h)
				if shader then shader:use(false) end
				
				-- Display letter mark over the portrait
				local stxt = self.turntracker[a].txt_turntracker_marker
				if not stxt then
					local txt = tostring(a.turntracker_marker)
					local fw, fh = self.buff_font_small:size(txt)
					self.turntracker[a].txt_turntracker_marker = self.buff_font_small:draw(txt, fw, colors.LIGHT_BLUE.r, colors.LIGHT_BLUE.g, colors.LIGHT_BLUE.b, true)[1]
					stxt = self.turntracker[a].txt_turntracker_marker
					stxt.fw, stxt.fh = fw, fh
				end
				if shader then
					shader:use(true)
					shader:uniOutlineSize(0.7, 0.7)
					shader:uniTextSize(stxt._tex_w, stxt._tex_h)
				else
					stxt._tex:toScreenFull(x-stxt.fw+18+1, y+16+1, stxt.w, stxt.h, stxt._tex_w, stxt._tex_h, 0, 0, 0, self.shadow or 0.6)
				end
				stxt._tex:toScreenFull(x-stxt.fw+18, y+16, stxt.w, stxt.h, stxt._tex_w, stxt._tex_h)
				if shader then shader:use(false) end

				-- Display high-speed marker
				if a:getSpeed("movement") < 1 or a:getSpeed("weapon") < 1 or a:getSpeed("spell") < 1 or a:getSpeed("mind") < 1 then
					local txt = "+"
					local fw, fh = self.buff_font_small:size(txt)
					local wtxt = self.buff_font_small:draw(txt, fw, colors.LIGHT_GREEN.r, colors.LIGHT_GREEN.g, colors.LIGHT_GREEN.b, true)[1]
					wtxt.fw, wtxt.fh = fw, fh
					if shader then
						shader:use(true)
						shader:uniOutlineSize(0.7, 0.7)
						shader:uniTextSize(wtxt._tex_w, wtxt._tex_h)
					else
						wtxt._tex:toScreenFull(x-wtxt.fw+36+1, y+16+1, wtxt.w, wtxt.h, wtxt._tex_w, wtxt._tex_h, 0, 0, 0, self.shadow or 0.6)
					end
					wtxt._tex:toScreenFull(x-wtxt.fw+36, y+16, wtxt.w, wtxt.h, wtxt._tex_w, wtxt._tex_h)
					if shader then shader:use(false) end
				end
				
			end
			
			self.turntracker[a] = {
				a, "turntracker"..a.uid, draw_fct, desc_fct
			}
		end
		if not game.mouse:getZone("turntracker"..i) and not game.mouse:updateZone("turntracker"..i, bx+x*scale, by+y*scale, hs, hs, self.turntracker[a][4], scale) then
			game.mouse:unregisterZone("turntracker"..i)
			game.mouse:registerZone(bx+x*scale, by+y*scale, hs, hs, self.turntracker[a][4], nil, "turntracker"..i, true, scale)
		end
		if not tooltip_drawn["turntracker"..i] then
			game.mouse:updateZone("turntracker"..i, bx+x*scale, by+y*scale, hs, hs, self.turntracker[a][4], scale)
			tooltip_drawn["turntracker"..i] = true
		end
		--call function
		self.turntracker[a][3](x, y, ents[i].t)
		is_first = false
		x, y = self:partyOrientStep(orient, bx, by, scale, x, y, hs, hs)
	end

	if not self.locked then
			move_handle[1]:toScreenFull(portrait[6] - move_handle[6], 0, move_handle[6], move_handle[7], move_handle[2], move_handle[3])
	end
	
	-- if not self.locked then
	-- 	local smhpwc = self.mhandle_pos.turntracker
	-- 	move_handle[1]:toScreenFull(smhpwc.x, smhpwc.y, move_handle[6], move_handle[7], move_handle[2], move_handle[3])
	-- end
	self:computePadding("turntracker", bx, by, bx + x * scale, by + y * scale)
end

local hk1 = {imageLoader("hotkeys/hotkey_1.png"):glTexture()}
local hk2 = {imageLoader("hotkeys/hotkey_2.png"):glTexture()}
local hk3 = {imageLoader("hotkeys/hotkey_3.png"):glTexture()}
local hk4 = {imageLoader("hotkeys/hotkey_4.png"):glTexture()}
local hk5 = {imageLoader("hotkeys/hotkey_5.png"):glTexture()}
local hk6 = {imageLoader("hotkeys/hotkey_6.png"):glTexture()}
local hk7 = {imageLoader("hotkeys/hotkey_7.png"):glTexture()}
local hk8 = {imageLoader("hotkeys/hotkey_8.png"):glTexture()}
local hk9 = {imageLoader("hotkeys/hotkey_9.png"):glTexture()}

-- copy of displayHotkeys that uses our new tid parameter from the engine
function _M:displayHotkeys(scale, bx, by)
	local hkeys = self.hotkeys_display
	local ox, oy = hkeys.display_x, hkeys.display_y

	hk5[1]:toScreenFull(0, 0, self.places.hotkeys.w, self.places.hotkeys.h, hk5[2], hk5[3])

	hk8[1]:toScreenFull(0, -hk8[7], self.places.hotkeys.w, hk8[7], hk8[2], hk8[3])
	hk2[1]:toScreenFull(0, self.places.hotkeys.h, self.places.hotkeys.w, hk2[7], hk2[2], hk2[3])
	hk4[1]:toScreenFull(-hk4[6], 0, hk4[6], self.places.hotkeys.h, hk4[2], hk4[3])
	hk6[1]:toScreenFull(self.places.hotkeys.w, 0, hk6[6], self.places.hotkeys.h, hk6[2], hk6[3])

	hk7[1]:toScreenFull(-hk7[6], -hk7[6], hk7[6], hk7[7], hk7[2], hk7[3])
	hk9[1]:toScreenFull(self.places.hotkeys.w, -hk9[6], hk9[6], hk9[7], hk9[2], hk9[3])
	hk1[1]:toScreenFull(-hk7[6], self.places.hotkeys.h, hk1[6], hk1[7], hk1[2], hk1[3])
	hk3[1]:toScreenFull(self.places.hotkeys.w, self.places.hotkeys.h, hk3[6], hk3[7], hk3[2], hk3[3])

	hkeys.orient = self.sizes.hotkeys and self.sizes.hotkeys.orient or "down"
	hkeys.display_x, hkeys.display_y = 0, 0
	hkeys:toScreen()
	hkeys.display_x, hkeys.display_y = ox, oy

	if not self.locked then
		move_handle[1]:toScreenFull(util.getval(self.mhandle_pos.hotkeys.x, self), util.getval(self.mhandle_pos.hotkeys.y, self), move_handle[6], move_handle[7], move_handle[2], move_handle[3])
	end

	if not game.mouse:updateZone("hotkeys", bx, by, self.places.hotkeys.w, self.places.hotkeys.h, nil, scale) then
		game.mouse:unregisterZone("hotkeys")

		local desc_fct = function(button, mx, my, xrel, yrel, bx, by, event)
			if event == "out" then
				self.turntracker_selected_tid = nil
				print("minimalist:talenthover: cleared")
				self.mhandle.hotkeys = nil
				self.hotkeys_display.cur_sel = nil
				return
			else self.mhandle.hotkeys = true end

			-- Move handle
			local mhx, mhy = util.getval(self.mhandle_pos.hotkeys.x, self), util.getval(self.mhandle_pos.hotkeys.y, self)
			if not self.locked and bx >= mhx and bx <= mhx + move_handle[6] and by >= mhy and by <= mhy + move_handle[7] then
				self:uiMoveResize("hotkeys", button, mx, my, xrel, yrel, bx, by, event, "resize", function(mode)
					hkeys:resize(self.places.hotkeys.x, self.places.hotkeys.y, self.places.hotkeys.w, self.places.hotkeys.h)
				end)
				return
			end

			-- if event == "button" and button == "left" and ((game.zone and game.zone.wilderness and not game.player.allow_talents_worldmap) or (game.key ~= game.normal_key)) then return end
			self.hotkeys_display:onMouse(button, mx, my, event == "button",
				function(text, tid)
					text = text:toTString()
					self.turntracker_selected_tid = tid
					print("minimalist:talenthover:", tid)
					text:add(true, "---", true, {"font","italic"}, {"color","GOLD"}, _t"Left click to use", true, _t"Right click to configure", true, _t"Press 'm' to setup", {"color","LAST"}, {"font","normal"})
					game:tooltipDisplayAtMap(game.w, game.h, text)
				end,
				function(i, hk)
					if button == "right" and hk and hk[1] == "talent" then
						local d = require("mod.dialogs.UseTalents").new(game.player)
						d:use({talent=hk[2], name=game.player:getTalentFromId(hk[2]).name}, "right")
						return true
					elseif button == "right" and hk and hk[1] == "inventory" then
						Dialog:yesnoPopup(("Unbind %s"):tformat(hk[2]), _t"Remove this object from your hotkeys?", function(ret) if ret then
							for i = 1, 12 * game.player.nb_hotkey_pages do
								if game.player.hotkey[i] and game.player.hotkey[i][1] == "inventory" and game.player.hotkey[i][2] == hk[2] then game.player.hotkey[i] = nil end
							end
						end end)
						return true
					end
				end
			)
		end
		game.mouse:registerZone(bx, by, self.places.hotkeys.w, self.places.hotkeys.h, desc_fct, nil, "hotkeys", true, scale)
	end

	-- Compute how much space to reserve on the side
	self:computePadding("hotkeys", bx, by, bx + hkeys.w * scale, by + hkeys.h * scale)
end

return _M
