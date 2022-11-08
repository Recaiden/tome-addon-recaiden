local _M = loadPrevious(...)

function _M:getStatDesc(item)
	local stat_id = item.stat
	if not stat_id then return item.desc end
	local text = tstring{}
	text:merge(item.desc:toTString())
	text:add(true, true)
	local diff = self.actor:getStat(stat_id, nil, nil, true) - self.actor_dup:getStat(stat_id, nil, nil, true)
	local color = diff >= 0 and {"color", "LIGHT_GREEN"} or {"color", "RED"}
	local color_mark = {"color", "YELLOW"}
	local color_end = {"color", "LIGHT_BLUE"}
	local dc = {"color", "LAST"}

	text:add(_t"Current value: ", {"color", "LIGHT_GREEN"}, ("%d"):format(self.actor:getStat(stat_id)), dc, true)
	text:add(_t"Base value: ", {"color", "LIGHT_GREEN"}, ("%d"):format(self.actor:getStat(stat_id, nil, nil, true)), dc, true, true)

	text:add({"color", "LIGHT_BLUE"}, _t"Stat gives:", dc, true)
	if stat_id == self.actor.STAT_CON then
		local multi_life = 4 + (self.actor.inc_resource_multi.life or 0)
		local added_life = diff * multi_life
		text:add(_t"Max life: ",
						 color_mark, ("%d"):format(self.actor_dup.max_life), dc,
						 " + ", color, ("%0.2f"):format(added_life), dc,
						 " => ", color_end, ("%d"):format(self.actor.max_life), dc, true)
		text:add(_t"Physical save: ",
						 color_mark, ("%0.2f"):format(self.actor_dup:combatPhysicalResistRaw(true)), dc,
						 " + ", color, ("%0.2f"):format(diff * 0.35), dc,
						 " => ", color_end, ("%0.2f (%d effective)"):format(self.actor:combatPhysicalResistRaw(true), self.actor:combatPhysicalResist(true)), dc, true)
		text:add(_t"Healing mod: ",
						 color_mark, ("%0.1f%%"):format(self.actor_dup.healing_factor*100), dc,
						 " + ", color, ("%0.1f%%"):format((self.actor:combatStatLimit("con", 1.5, 0, 0.5) - self.actor_dup:combatStatLimit("con", 1.5, 0, 0.5))*100), dc,
						 " => ", color_end, ("%0.1f%%"):format(self.actor.healing_factor*100), dc, true)
	elseif stat_id == self.actor.STAT_WIL then
		if self.actor:knowTalent(self.actor.T_MANA_POOL) then
			local multi_mana = 5 + (self.actor.inc_resource_multi.mana or 0)
			text:add(_t"Max mana: ", color, ("%0.2f"):format(diff * multi_mana), dc, true)
		end
		if self.actor:knowTalent(self.actor.T_STAMINA_POOL) then
			local multi_stamina = 2.5 + (self.actor.inc_resource_multi.stamina or 0)
			text:add(_t"Max stamina: ", color, ("%0.2f"):format(diff * multi_stamina), dc, true)
		end
		if self.actor:knowTalent(self.actor.T_PSI_POOL) then
			local multi_psi = 1 + (self.actor.inc_resource_multi.psi or 0)
			text:add(_t"Max psi: ", color, ("%0.2f"):format(diff * multi_psi), dc, true)
		end
		text:add(_t"Mindpower: ", color, ("%0.2f"):format(diff * 0.7), dc, true)
		text:add(_t"Mental save: ", color, ("%0.2f"):format(diff * 0.35), dc, true)
		text:add(_t"Spell save: ", color, ("%0.2f"):format(diff * 0.35), dc, true)
--		if self.actor:attr("use_psi_combat") then
--			text:add("Accuracy: ", color, ("%0.2f"):format(diff * 0.35), dc, true)
--		end
	elseif stat_id == self.actor.STAT_STR then
		text:add(_t"Physical power: ", color, ("%0.2f"):format(diff), dc, true)
		text:add(_t"Max encumbrance: ", color, ("%0.2f"):format(diff * 1.8), dc, true)
		text:add(_t"Physical save: ", color, ("%0.2f"):format(diff * 0.35), dc, true)
	elseif stat_id == self.actor.STAT_CUN then
		text:add(_t"Crit. chance: ", color, ("%0.2f"):format(diff * 0.3), dc, true)
		text:add(_t"Mental save: ", color, ("%0.2f"):format(diff * 0.35), dc, true)
		text:add(_t"Mindpower: ", color, ("%0.2f"):format(diff * 0.4), dc, true)
		if self.actor:attr("use_psi_combat") then
			text:add(_t"Accuracy: ", color, ("%0.2f"):format(diff * 0.35), dc, true)
		end
	elseif stat_id == self.actor.STAT_MAG then
		text:add(_t"Spell save: ", color, ("%0.2f"):format(diff * 0.35), dc, true)
		text:add(_t"Spellpower: ", color, ("%0.2f"):format(diff * 1), dc, true)
	elseif stat_id == self.actor.STAT_DEX then
		text:add(_t"Defense: ", color, ("%0.2f"):format(diff * 0.35), dc, true)
		text:add(_t"Ranged defense: ", color, ("%0.2f"):format(diff * 0.35), dc, true)
		text:add(_t"Accuracy: ", color, ("%0.2f"):format(diff), dc, true)
		text:add(_t"Shrug off criticals chance: ", color, ("%0.2f%%"):format(diff * 0.3), dc, true)
	end

	if self.actor.player and self.desc_def and self.desc_def.getStatDesc and self.desc_def.getStatDesc(stat_id, self.actor) then
		text:add({"color", "LIGHT_BLUE"}, _t"Class powers:", dc, true)
		text:add(self.desc_def.getStatDesc(stat_id, self.actor))
	end
	return text
end

return _M
