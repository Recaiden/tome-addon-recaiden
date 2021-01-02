local _M = loadPrevious(...)

require "engine.class"

local page_to_hotkey = {"", "SECOND_", "THIRD_", "FOURTH_", "FIFTH_", "SIX_", "SEVEN_"}


function _M:onMouse(button, mx, my, click, on_over, on_click)
	local orient = self.orient or "down"
	mx, my = mx - self.display_x, my - self.display_y
	local a = self.actor

	if button == "wheelup" and click then
		a:prevHotkeyPage()
		return
	elseif button == "wheeldown" and click then
		a:nextHotkeyPage()
		return
	elseif button == "drag-end" then
		local drag = game.mouse.dragged.payload
--		print(table.serialize(drag,nil,true))
		if drag.kind == "talent" or drag.kind == "inventory" then
			for i, zone in pairs(self.dragclics) do
				if mx >= zone[1] and mx < zone[1] + zone[3] and my >= zone[2] and my < zone[2] + zone[4] then
					local old = self.actor.hotkey[i]

					if i <= #page_to_hotkey * 12 then -- Only add this hotkey if we support a valid page for it.
						self.actor.hotkey[i] = {drag.kind, drag.id}

						if drag.source_hotkey_slot then
							self.actor.hotkey[drag.source_hotkey_slot] = old
						end

						-- Update the quickhotkeys table immediately rather than waiting for a save.
						if self.actor.save_hotkeys then
							engine.interface.PlayerHotkeys:updateQuickHotkey(self.actor, i)
							engine.interface.PlayerHotkeys:updateQuickHotkey(self.actor, drag.source_hotkey_slot)
						end
					end
					game.mouse:usedDrag()
					self.actor.changed = true
					break
				end
			end
		end
	end

	for i, zone in pairs(self.clics) do
		if mx >= zone[1] and mx < zone[1] + zone[3] and my >= zone[2] and my < zone[2] + zone[4] then
			if on_click and click and not zone.fake then
				if on_click(i, a.hotkey[i]) then click = false end
			end
			local oldsel = self.cur_sel
			self.cur_sel = i
			if button == "left" and not zone.fake then
				if click then
					a:activateHotkey(i)
				else
					if a.hotkey[i][1] == "talent" then
						local t = self.actor:getTalentFromId(a.hotkey[i][2])
						local s = nil
						if t then s = t.display_entity:getEntityFinalSurface(nil, 64, 64) end
						game.mouse:startDrag(mx, my, s, {kind=a.hotkey[i][1], id=a.hotkey[i][2], source_hotkey_slot=i}, function(drag, used) if not used then self.actor.hotkey[i] = nil self.actor.changed = true end end)
					elseif a.hotkey[i][1] == "inventory" then
						local o = a:findInAllInventories(a.hotkey[i][2], {no_add_name=true, force_id=true, no_count=true})
						local s = nil
						if o then s = o:getEntityFinalSurface(nil, 64, 64) end
						game.mouse:startDrag(mx, my, s, {kind=a.hotkey[i][1], id=a.hotkey[i][2], source_hotkey_slot=i}, function(drag, used) if not used then self.actor.hotkey[i] = nil self.actor.changed = true end end)
					end
				end
			elseif button == "right" and click and not zone.fake then
				a.hotkey[i] = nil
				a.changed = true
			else
				a.changed = true
				if on_over and self.cur_sel ~= oldsel and not zone.fake then
					local text = ""
					local other = nil
					if a.hotkey[i] and a.hotkey[i][1] == "talent" then
						other  = a.hotkey[i][2]
						local t = self.actor:getTalentFromId(a.hotkey[i][2])
						if t then
							text = tstring{{"color","GOLD"}, {"font", "bold"}, t.name .. (config.settings.cheat and " ("..t.id..")" or ""), {"font", "normal"}, {"color", "LAST"}, true}
							text:merge(self.actor:getTalentFullDescription(t))
						else text = _t"Unknown!" end
					elseif a.hotkey[i] and a.hotkey[i][1] == "inventory" then
						local o = a:findInAllInventories(a.hotkey[i][2], {no_add_name=true, force_id=true, no_count=true})
						if o then
							text = o:getDesc()
						else text = _t"Missing!" end
					end
					print("onMouse:talenthover:", other)
					on_over(text, other)
				end
			end
			return
		end
	end
	self.cur_sel = nil
end


return _M