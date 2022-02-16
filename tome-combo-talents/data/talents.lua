local Talents = require "engine.interface.ActorTalents"
local Tiles = require "engine.Tiles"
local Entity = require "engine.Entity"

pre_use_combo = function(self, t, silent, i)
	if not self.rec_combo or not self.rec_combo[i] then return false end
	local combo = self.rec_combo[i]
	if self.turn_procs and self.turn_procs.combo_override then return true end
	for tid, _ in pairs(combo) do
		local t_sub = self:getTalentFromId(tid)
		local valid = true
		if t_sub.on_pre_use and t_sub.on_pre_use(self, t_sub, silent) ~= true then valid = false end
		if self:isTalentCoolingDown(t_sub) then valid = false end
		if not valid then
			if not silent then
				game.logPlayer(self, "Part of this combo cannot be used.  Use to combo again to activate it anyway.")
				self.turn_procs = self.turn_procs or {}
				self.turn_procs.combo_override = true
			end
			return false
		end
		return true
	end
end

comboNoEnergy = function(self, i)
	if not self.rec_combo or not self.rec_combo[i] then return true end
	local combo = self.rec_combo[i]
	for tid, _ in pairs(combo) do
		local t_sub = self:getTalentFromId(tid)
		if not util.getval(t_sub.no_energy, self, t) then return false end
	end
	return true
end

comboGetSpeed = function(self, i)
	if not self.rec_combo or not self.rec_combo[i] then return 1.0 end
	local is_instant = util.getval(t.no_energy, self, t) == true
	local combo = self.rec_combo[i]
	for tid, _ in pairs(combo) do
		local t_sub = self:getTalentFromId(tid)
		if not util.getval(t_sub.no_energy, self, t) then return self:getTalentSpeed(t_sub) end
	end
	return 1.0
end

comboExecute = function(self, i)
	if not self.rec_combo or not self.rec_combo[i] then return false end
	local combo = self.rec_combo[i]
	for tid, _ in pairs(combo) do
		self:forceUseTalent(tid, {ignore_energy=true})
	end
	return true
end

if not Talents.talents_types_def["base/combo"] then
   newTalentType{ type="base/combo", name = _t("Combos", "talent type"), description = _t"Use talents together." }
end

newTalent{
  name = "Combo", short_name = "REK_COMBO_ONE", image = "talents/rek_combo_one.png",
  type = {"base/combo", 1}, points = 1,
  cooldown = 0,
	innate = true,
  no_npc_use = true,
	combo_number = 1,
	speed = function(self, t) return comboGetSpeed(self, t.combo_number) end,
	no_energy = function(self, t) return comboNoEnergy(self, t, t.combo_number) end,
	on_pre_use = function(self, t, silent)
		return pre_use_combo(self, t, silent, t.combo_number)
	end,
  action = function(self, t)
		return comboExecute(self, t.combo_number)
  end,
  info = function(self, t)
		local base = ([[Activate the following prepared talents one after the other:]]):tformat()
		if not self.rec_combo then return base end
		local combo = self.rec_combo[t.combo_number] or {}
		for tid, _ in pairs(combo) do
			local t_sub = self:getTalentFromId(tid)
			base = base..([[
 - %s]]):tformat(t_sub.name)
		end
		return base
  end,
}
