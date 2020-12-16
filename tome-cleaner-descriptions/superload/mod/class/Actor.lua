local _M = loadPrevious(...)

local Actor = require "engine.Actor"
local Faction = require "engine.Faction"
local Dialog = require "engine.ui.Dialog"
local Map = require "engine.Map"
local Chat = require "engine.Chat"
local DamageType = require "engine.DamageType"
local Object = require("mod.class.Object")

mod_align_stat = Object.mod_align_stat
mod_hl_values = Object.mod_hl_values
mod_USABLE_COLOR = "ffff66"
local base = _M.getTalentFullDescription

function _M:getTalentFullDescription(t, addlevel, config, fake_mastery)
  if not config or not config.tooltip_mode then
    return base(self, t, addlevel, config, fake_mastery)
  end

	if not t then return tstring{"no talent"} end

	config = config or {}
	local old = self.talents[t.id]
	if config.force_level then
		self.talents[t.id] = config.force_level
	else
		self.talents[t.id] = (self.talents[t.id] or 0) + (addlevel or 0)
	end

	local oldmastery = nil
	if fake_mastery then
		self.talents_types_mastery[t.type[1]] = fake_mastery - 1
	end

	local d = tstring{}
	if not config.ignore_level then
		d:add({"color",0x6f,0xff,0x83}, _t"Effective talent level: ", {"color",0x00,0xFF,0x00}, ("%.1f"):format(self:getTalentLevel(t)), true)
	end

	if not config.ignore_mode then
		if t.mode == "passive" then d:add({"color",0x6f,0xff,0x83}, _t"Use mode: ", {"color",0x00,0xFF,0x00}, _t"Passive", true)
		elseif t.mode == "sustained" then d:add({"color",0x6f,0xff,0x83}, _t"Use mode: ", {"color",0x00,0xFF,0x00}, _t"Sustained", true)
		else d:add({"color",0x6f,0xff,0x83}, _t"Use mode: ", {"color",0x00,0xFF,0x00}, _t"Activated", true)
		end
	end

	if config.custom then
		d:merge(config.custom)
		d:add(true)
	end
	if not config.ignore_ressources then
		if t.feedback then d:add({"color",0x6f,0xff,0x83}, _t"Feedback cost: ", {"color",0xFF, 0xFF, 0x00}, ""..math.round(util.getval(t.feedback, self, t) * (100 + 2 * self:combatFatigue()) / 100, 0.1), true) end
		if t.fortress_energy then d:add({"color",0x6f,0xff,0x83}, _t"Fortress Energy cost: ", {"color",0x00,0xff,0xa0}, ""..math.round(t.fortress_energy, 0.1), true) end
		if t.sustain_feedback then d:add({"color",0x6f,0xff,0x83}, _t"Sustain feedback cost: ", {"color",0xFF, 0xFF, 0x00}, ""..(util.getval(t.sustain_feedback, self, t)), true) end

		-- resource costs?
		for res, res_def in ipairs(_M.resources_def) do
			if not res_def.hidden_resource then
				-- list resource cost
				local cost = t[res_def.short_name] and util.getval(t[res_def.short_name], self, t) or 0
				cost = self:alterTalentCost(t, res_def.short_name, cost)
				if cost ~= 0 then
					cost = cost * (util.getval(res_def.cost_factor, self, t, false, cost) or 1)
					d:add({"color",0x6f,0xff,0x83}, ("%s %s: "):tformat(res_def.name:capitalize(), cost >= 0 and _t"cost" or _t"gain"), res_def.color or {"color",0xff,0xa8,0xa8}, ""..math.round(math.abs(cost), .1), true)
				end
				-- list sustain cost
				cost = t[res_def.sustain_prop] and util.getval(t[res_def.sustain_prop], self, t) or 0
				cost = self:alterTalentCost(t, res_def.sustain_prop, cost)
				if cost ~= 0 then
					d:add({"color",0x6f,0xff,0x83}, ("Sustain %s cost: "):tformat(res_def.name:lower()), res_def.color or {"color",0xff,0xa8,0xa8}, ""..math.round(cost, .1), true)
				end
				-- list drain cost
				cost = t[res_def.drain_prop] and util.getval(t[res_def.drain_prop], self, t) or 0
				cost = self:alterTalentCost(t, res_def.drain_prop, cost)
				if cost ~= 0 then
					if res_def.invert_values then
						d:add({"color",0x6f,0xff,0x83}, ("%s %s: "):tformat(cost > 0 and _t"Generates" or _t"Removes", res_def.name:lower()), res_def.color or {"color",0xff,0xa8,0xa8}, ""..math.round(math.abs(cost), .1), true)
					else
						d:add({"color",0x6f,0xff,0x83}, ("%s %s: "):tformat(cost > 0 and _t"Drains" or _t"Replenishes", res_def.name:lower()), res_def.color or {"color",0xff,0xa8,0xa8}, ""..math.round(math.abs(cost), .1), true)
					end
				end
			end
		end
		self:triggerHook{"Actor:getTalentFullDescription:ressources", str=d, t=t, addlevel=addlevel, config=config, fake_mastery=fake_mastery}
	end
	if t.mode ~= "passive" then
		if not config.ignore_range then
			if t.range or not config.ignore_blank_range then
				if self:getTalentRange(t) > 1 then d:add({"color",0x6f,0xff,0x83}, mod_align_stat( "Range" ), {"color",0xFF,0xFF,0xFF}, ("%d"):format(self:getTalentRange(t)), true)
				else d:add({"color",0x6f,0xff,0x83}, mod_align_stat( "Range" ), {"color",0xFF,0xFF,0xFF}, "melee/personal", true)
				end
			end
		end
		if not config.ignore_cooldown then
			if self:getTalentCooldown(t) then d:add({"color",0x6f,0xff,0x83}, ("%sCooldown: "):tformat(t.fixed_cooldown and _t"Fixed " or ""), {"color",0xFF,0xFF,0xFF}, ""..self:getTalentCooldown(t), true) end
		end
		if not config.ignore_travel_speed then
			local speed = self:getTalentProjectileSpeed(t)
			if speed then d:add({"color",0x6f,0xff,0x83}, mod_align_stat( "Travel.spd" ), {"color",0xFF,0xFF,0xFF}, ""..(speed * 100).."% of base", true)
			else d:add({"color",0x6f,0xff,0x83}, mod_align_stat( "Travel.spd" ), {"color",0xFF,0xFF,0xFF}, "instantaneous", true)
			end
		end
		if not config.ignore_use_time then
			local uspeed = _t"Full Turn"
			local no_energy = util.getval(t.no_energy, self, t)
			local display_speed = util.getval(t.display_speed, self, t)
			if display_speed then
				uspeed = display_speed
			elseif no_energy and type(no_energy) == "boolean" and no_energy == true then
				uspeed = _t"Instant (#LIGHT_GREEN#0%#LAST# of a turn)"
			else
				local speed = self:getTalentSpeed(t)
				local speed_type = self:getTalentSpeedType(t)
				if type(speed_type) == "string" then
					speed_type = _t(speed_type):capitalize()
				else
					speed_type = _t'Special'
				end
				uspeed = ("%s (#LIGHT_GREEN#%d%%#LAST# of a turn)"):tformat(speed_type, speed * 100)
			end
			d:add({"color",0x6f,0xff,0x83}, _t"Usage Speed: ", {"color",0xFF,0xFF,0xFF}, uspeed, true)
			if t.no_break_stealth ~= nil and no_energy ~= true and self:knowTalent(self.T_STEALTH) then
				local nbs, chance = t.no_break_stealth
				if type(t.no_break_stealth) == "function" then
					nbs, chance = t.no_break_stealth(self, t)
					if type(chance) ~= "number" then
						chance = nbs and 100 or 0
					end
				else chance = nbs and 100 or 0
				end
				if chance > 0 then
					d:add({"color",0x6f,0xff,0x83}, _t"Won't Break Stealth:  ", {"color",0xFF,0xFF,0xFF}, ("%d%%"):format(chance), true)
				end
			end
		end
	else
		if not config.ignore_cooldown then
			if self:getTalentCooldown(t) then d:add({"color",0x6f,0xff,0x83}, ("%sCooldown: "):tformat(t.fixed_cooldown and _t"Fixed " or ""), {"color",0xFF,0xFF,0xFF}, ""..self:getTalentCooldown(t), true) end
		end
	end
	
	local is_a = {}
	for is, desc in pairs(engine.interface.ActorTalents.is_a_type) do
		if t[is] then is_a[#is_a+1] = desc end
	end
	if #is_a > 0 then
		d:add({"color",0x6f,0xff,0x83}, _t"Is: ", {"color",0xFF,0xFF,0xFF}, table.concatNice(is_a, ", ", _t" and "), true)
	end

	if t.mode == 'sustained' then
		local replaces = self:getReplacedSustains(t)
		if #replaces > 0 then
			for k, v in pairs(replaces) do replaces[k] = self:getTalentFromId(v).name end
			d:add({"color",0x6f,0xff,0x83}, _t"Will Deactivate: ", {"color",0xFF,0xFF,0xFF}, table.concat(replaces, ', '), true)
		end
	end

	self:triggerHook{"Actor:getTalentFullDescription", str=d, t=t, addlevel=addlevel, config=config, fake_mastery=fake_mastery}

	d:add({"color",0x6f,0xff,0x83}, _t"Description: ", {"color",0xFF,0xFF,0xFF})
	d:merge(t.info(self, t):toTString():tokenize(" ()[],"))

	self.talents[t.id] = old

	if fake_mastery then
		self.talents_types_mastery[t.type[1]] = oldmastery
	end

	return d
end

return _M