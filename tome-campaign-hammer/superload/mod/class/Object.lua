-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2016 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

local _M = loadPrevious(...)

local getCharmPower = _M.getCharmPower
function _M:getCharmPower(who, raw)
	if self.steamtech_power_def then 
		local v = self.steamtech_power_def(self, who)
		if self.uses_medical_injector then
			local data = who:getMedicalInjector()
			if data then
				return v * (data.power + data.inc_stat) / 100
			else
				return v
			end
		end
	end
	return getCharmPower(self, who, raw)
end

--- can the object be used?
--	@param who = the object user (optional)
--	returns boolean, msg
local canUseObject = _M.canUseObject
function _M:canUseObject(who)
	if who then
		if self.is_medical_salve and not who:getMedicalInjector() then return false, "You have no medical injector available." end
	end
	return canUseObject(self, who)
end


function _M:orcsWeaponAddOnEffect(effect, kind, def)
	if not self.combat then return end
	if not self.combat[effect] then self.combat[effect] = {} end
	if self.combat[effect].fct then self.combat[effect] = {self.combat[effect]} end
	def._kind = kind
	table.insert(self.combat[effect], def)
end

function _M:orcsWeaponRemoveOnEffect(effect, kind)
	if not self.combat then return end
	if not self.combat[effect] then return end
	if self.combat[effect].fct then return end
	for i, def in ipairs(self.combat[effect]) do
		if def._kind == kind then
			table.remove(self.combat[effect], i)
			break
		end
	end
end

return _M
