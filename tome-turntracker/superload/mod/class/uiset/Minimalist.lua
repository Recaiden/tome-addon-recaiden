local _M = loadPrevious(...)

local UI = require "engine.ui.Base"

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
end

function _M:displayTurntracker(scale, bx, by)
	local player = game.player
	if not game.level then
		self.turntracker = {}
	elseif game.player.changed and next(self.turntracker) then
		for a, d in pairs(self.turntracker) do if not game.party:hasMember(a) and (not player:hasLOS(a.x, a.y) and player:canSee(a)) then game.mouse:unregisterZone(d[2]) end end
			self.turntracker = {}
	end

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

				while ticksRemaining < cutoff do
					eRemaining = eRemaining + game.energy_to_act
					ticksRemaining = (eRemaining / 100) / act.global_speed
					entities[#entities+1] = {a=act, t=ticksRemaining}
				end
			end
		end
	end
	table.sort(entities, function(a, b) return a.t < b.t end)
	-- cap list
	local count = #entities
	for i=11, count do entities[i]=nil end
	
	-- Draw list	
	local orient = self.sizes.turntracker and self.sizes.turntracker.orient or "down"
	local hs = portrait[7] + 3
	local x, y = 0, 0
	local is_first = true

	local tooltip_drawn = {}
	for i = 1, #entities do
		local a = entities[i].a
		if not self.turntracker[a] then
			a.turntracker_ticks = entities[i].t
			
			local text = ("#GOLD##{bold}#%s\n#WHITE##{normal}#Life: %d%%\nMove  Speed: %d%%\nAttck Speed: %d%%\nSpell Speed: %d%%\nMind  Speed: %d%%"):tformat(a:getName(), math.floor(100 * a.life / a.max_life), 100/a:getSpeed("movement"), 100/a:getSpeed("weapon"), 100/a:getSpeed("spell"), 100/a:getSpeed("mind"))
			if a.summon_time then text = text..("\nTurns remaining: %s"):tformat(a.summon_time) end
			local is_first = (i == 1)
			local desc_fct = function(button, mx, my, xrel, yrel, bx, by, event)
				if is_first then
					if event == "out" then self.mhandle.turntracker = nil return
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
		--not game.mouse:getZone("turntracker"..a.uid) and
		if not game.mouse:getZone("turntracker"..a.uid) and not game.mouse:updateZone("turntracker"..a.uid, bx+x*scale, by+y*scale, hs, hs, self.turntracker[a][4], scale) then
			game.mouse:unregisterZone("turntracker"..a.uid)
			game.mouse:registerZone(bx+x*scale, by+y*scale, hs, hs, self.turntracker[a][4], nil, "turntracker"..a.uid, true, scale)
			
		end
		if not tooltip_drawn[a.uid] then
			game.mouse:updateZone("turntracker"..a.uid, bx+x*scale, by+y*scale, hs, hs, self.turntracker[a][4], scale)
			tooltip_drawn[a.uid] = true
		end
		--call function
		self.turntracker[a][3](x, y, entities[i].t)
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