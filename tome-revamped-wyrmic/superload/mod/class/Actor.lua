local _M = loadPrevious(...)


local base_onWear = _M.onWear
function _M:onWear(o, inven_id, bypass_set)
	if self:knowTalent(self.T_REK_WYRMIC_PREDATOR_GEM) and o.wielder and o.type == "gem" then
		local factor = self:callTalent(self.T_REK_WYRMIC_PREDATOR_GEM, "getGemBonus")
		
		o.__rek_jewel_adds = {}
		-- stats, armor, defense, saves, crit, stun_resist, affinity, damage increases, pen, dodge, movespeed
		if o.wielder.combat_spellresist then o:tableTemporaryValue(o.__rek_jewel_adds, {"wielder", "combat_spellresist"}, math.ceil(o.wielder.combat_spellresist * factor)) end
		if o.wielder.combat_physresist then o:tableTemporaryValue(o.__rek_jewel_adds, {"wielder", "combat_physresist"}, math.ceil(o.wielder.combat_physresist * factor)) end
		if o.wielder.combat_mentalresist then o:tableTemporaryValue(o.__rek_jewel_adds, {"wielder", "combat_mentalresist"}, math.ceil(o.wielder.combat_mentalresist * factor)) end
		if o.wielder.combat_armor then o:tableTemporaryValue(o.__rek_jewel_adds, {"wielder", "combat_armor"}, math.ceil(o.wielder.combat_armor * factor)) end
		if o.wielder.combat_def then o:tableTemporaryValue(o.__rek_jewel_adds, {"wielder", "combat_def"}, math.ceil(o.wielder.combat_def * factor)) end
		if o.wielder.inc_stats then 
			local adds = {}
			for k, v in pairs(o.wielder.inc_stats) do adds[k] = math.ceil(v * factor) end
         o:tableTemporaryValue(o.__rek_jewel_adds, {"wielder", "inc_stats"}, adds)
		end
		if o.wielder.resists then 
			local adds = {}
			for k, v in pairs(o.wielder.resists) do adds[k] = math.ceil(v * factor) end
			o:tableTemporaryValue(o.__rek_jewel_adds, {"wielder", "resists"}, adds)
		end
		if o.wielder.resists_pen then 
			local adds = {}
			for k, v in pairs(o.wielder.resists_pen) do adds[k] = math.ceil(v * factor) end
			o:tableTemporaryValue(o.__rek_jewel_adds, {"wielder", "resists_pen"}, adds)
		end
		if o.wielder.inc_damage then 
			local adds = {}
			for k, v in pairs(o.wielder.inc_damage) do adds[k] = math.ceil(v * factor) end
			o:tableTemporaryValue(o.__rek_jewel_adds, {"wielder", "inc_damage"}, adds)
		end
		if o.wielder.damage_affinity then 
			local adds = {}
			for k, v in pairs(o.wielder.damage_affinity) do adds[k] = math.ceil(v * factor) end
			o:tableTemporaryValue(o.__rek_jewel_adds, {"wielder", "damage_affinity"}, adds)
		end
		if o.wielder.combat_physcrit then o:tableTemporaryValue(o.__rek_jewel_adds, {"wielder", "combat_physcrit"}, math.ceil(o.wielder.combat_physcrit * factor)) end
		if o.wielder.combat_mindcrit then o:tableTemporaryValue(o.__rek_jewel_adds, {"wielder", "combat_mindcrit"}, math.ceil(o.wielder.combat_mindcrit * factor)) end
		if o.wielder.combat_spellcrit then o:tableTemporaryValue(o.__rek_jewel_adds, {"wielder", "combat_spellcrit"}, math.ceil(o.wielder.combat_spellcrit * factor)) end
		if o.wielder.stun_immune then o:tableTemporaryValue(o.__rek_jewel_adds, {"wielder", "stun_immune"}, math.ceil(100 * o.wielder.stun_immune * factor)/100) end
		if o.wielder.cancel_damage_chance then o:tableTemporaryValue(o.__rek_jewel_adds, {"wielder", "cancel_damage_chance"}, math.ceil(o.wielder.cancel_damage_chance * factor)) end
		if o.wielder.movement_speed then
			o:tableTemporaryValue(o.__rek_jewel_adds, {"wielder", "movement_speed"}, math.ceil(100*o.wielder.movement_speed * factor)/100)
		end
	end
	
	base_onWear(self, o, inven_id, bypass_set)
end

--- Call when an object is taken off
local base_onTakeoff = _M.onTakeoff
function _M:onTakeoff(o, inven_id, bypass_set)
   base_onTakeoff(self, o, inven_id, bypass_set) 
   if o.__rek_jewel_adds then
      o:tableTemporaryValuesRemove(o.__rek_jewel_adds)
   end
end

return _M
