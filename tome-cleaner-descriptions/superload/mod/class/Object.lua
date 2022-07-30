require "engine.class"
require "engine.Object"
require "engine.interface.ObjectActivable"
require "engine.interface.ObjectIdentify"

local Stats = require("engine.interface.ActorStats")
local Talents = require("engine.interface.ActorTalents")
local DamageType = require("engine.DamageType")
local ActorResource = require "engine.interface.ActorResource"
local Combat = require("mod.class.interface.Combat")

local _M = loadPrevious(...)

local mod_max_tpl_len = { Minimalist = { small = { fantasy = 73, web = 73, basic = 73 },
                                         normal = { fantasy = 51, web = 51, basic = 59 },
                                         big = { fantasy = 45, web = 45, basic = 49 } },
                          Classic =    { small = { fantasy = 45, web = 45, basic = 45 },
                                         normal = { fantasy = 33, web = 33, basic = 33 },
                                         big = { fantasy = 29, web = 29, basic = 29 } } }

function mod_get_tlp_len( mode, font_size, font_type )
	if not mod_max_tpl_len then return 50 end
	if not mod_max_tpl_len[mode] then return 50 end
	if not mod_max_tpl_len[mode][font_size] then return mod_max_tpl_len[mode]["normal"]["basic"] end
	if not mod_max_tpl_len[mode][font_size][font_type] then return mod_max_tpl_len[mode][font_size]["basic"] end

	return mod_max_tpl_len[mode][font_size][font_type]
end

local mod_cur_tlp_len = mod_get_tlp_len( config.settings.tome.uiset_mode,
                                         config.settings.tome.fonts["size"],
                                         config.settings.tome.fonts["type"] )
local mod_USABLE_COLOR = "ffff66"
local mod_USABLE_COLOR2 = "999900"
local mod_PASS_PWR_COLOR = "4682B4"
local mod_DPS_sep = "#595959#offense ------#LAST#"
local mod_DEF_sep = "#595959#defense ------#LAST#"
-- local mod_DEF_sep = "#595959#--- defense ---#LAST#"
local mod_MISC_sep = "#595959#other -------#LAST#"

DamageType.dam_def.PHYSICALBLEED.name = "phys.bleed"
DamageType.dam_def.SPLIT_BLEED.name = "phys.bleed"
DamageType.dam_def.VOID.name = "void"

local mod_dam_def = { DISEASE   = DamageType.dam_def["BLIGHT"],
                      DISEASES  = DamageType.dam_def["BLIGHT"],
                      PIN       = DamageType.dam_def["PINNING"],
                      PINS      = DamageType.dam_def["PINNING"],
                      CUT       = DamageType.dam_def["BLEED"],
                      STUN      = DamageType.dam_def["PHYSICAL_STUN"],
                      STUNS     = DamageType.dam_def["PHYSICAL_STUN"],
                      CONFUSE   = DamageType.dam_def["CONFUSION"],
                      DAZE      = DamageType.dam_def["LIGHTNING_DAZE"],
                      DAZES     = DamageType.dam_def["LIGHTNING_DAZE"],
                      DAZING    = DamageType.dam_def["LIGHTNING_DAZE"],
                      DARK      = DamageType.dam_def["DARKNESS"],
                      CURSE     = DamageType.dam_def["DARKNESS"],
                      FREEZING  = DamageType.dam_def["FREEZE"],
                      DEMONFIRE = DamageType.dam_def["FIRE"],
                      KNOCK     = DamageType.dam_def["PHYSKNOCKBACK"],
                      KNOCKS    = DamageType.dam_def["PHYSKNOCKBACK"],
                      DEVOUR    = DamageType.dam_def["DEVOUR_LIFE"]
}

function mod_is_exceed_tlp( in_str )
	return tostring(in_str):gsub( "#.-#", "" ):len() > mod_cur_tlp_len
end

function mod_hl_values( in_str )
	if in_str:lower():match( "you have set the ring to grant you" ) then -- Writhing Ring of the Hunter fix
		return in_str
	end

	local excs = "#leaves#wave#clock#winter#fires#fired#grows#"
	function _def_dmg( _, in_s )
		if excs:find( "#"..in_s:lower().."#" ) then 
			return
		end
		local uppr = in_s:upper()
		local dam_def = mod_dam_def[uppr] or DamageType.dam_def[uppr] or DamageType.dam_def[uppr:sub(1,-2)]
		if dam_def then
			return _ .. (dam_def.text_color or "#WHITE#") .. in_s .. "#LAST#"
		end
	end
	
	function _def_dmg2( in_s )
		if in_s:lower():match( "fire" ) then
			return
		end
		return _def_dmg( "", in_s )
	end
	
	in_str = in_str:gsub( "([^#%w])(%w+)", _def_dmg )
	in_str = in_str:gsub( "^(%w+)", _def_dmg2 )
	in_str = in_str:gsub( "%%[%%]+", "%%" )
	in_str = in_str:gsub("([^#%x])([+-]?%d*%.*%d+[%%]*)","%1#LIGHT_GREEN#%2#LAST#")
	in_str = in_str:gsub("^[+-]?%d*%.*%d+[%%]*","#LIGHT_GREEN#%1#LAST#")
	return in_str
end
_M.mod_hl_values = mod_hl_values

function mod_align_stat( in_str, off_mod )
	off_mod = off_mod or 0
	in_str = in_str or ""
	local attr_offs = 18
	if string.len( in_str ) < attr_offs then
		return in_str .. string.rep(" ",attr_offs - string.len( in_str )+off_mod)
	else
		return in_str .. " "
	end
end
_M.mod_align_stat = mod_align_stat

function mod_eff_name( eff_name )
	return eff_name:gsub( " %% chance of ", "%% " )
end

--- Gets the full desc of the object
local base_getDesc = _M.getDesc
function _M:getDesc(name_param, compare_with, never_compare, use_actor)
	if core.key.modState("alt") then
		return base_getDesc(self, name_param, compare_with, never_compare, use_actor)
	end
	use_actor = use_actor or game.player
	local desc = tstring{}
	
	name_param = name_param or {}
	name_param.do_color = true
	compare_with = compare_with or {}

	-- item name
	desc:merge(self:getName(name_param):toTString())
	desc:add("#WHITE#",true)

	if self.encumber then
		local s_enc = ("%0.1f Encumbrance"):format(self.encumber)
		desc:add({"color",0x67,0xAD,0x00}, string.rep(" ",mod_cur_tlp_len-string.len(s_enc)-1) .. s_enc, {"color", "LAST"})
	end
	desc:add(true)
	
	local could_compare = false
	if not name_param.force_compare and not core.key.modState("ctrl") then
		if compare_with[1] then could_compare = true end
		compare_with = {}
	end
	
	desc:merge(self:getTextualDesc(compare_with, use_actor))

	if self:isIdentified() then
		desc:add(true, {"color", "ANTIQUE_WHITE"})
		desc:merge(self.desc:toTString())
		desc:add({"color", "WHITE"})
	end

	if self.shimmer_moddable then
		local oname = (self.shimmer_moddable.name or "???"):toTString()
		desc:add(true, {"color", "OLIVE_DRAB"}, "This object's appearance was changed to ")
		desc:merge(oname)
		desc:add(".", {"color","LAST"}, true)
	end

	if could_compare and not never_compare then desc:add(true, {"font","italic"}, {"color","GOLD"}, "Press <control> to compare", {"color","LAST"}, {"font","normal"}) end

	return desc
end

--- Gets the full textual desc of the object without the name and requirements
local base_getTextualDesc = _M.getTextualDesc
function _M:getTextualDesc(compare_with, use_actor)
	if core.key.modState("alt") then
		return base_getTextualDesc(self, compare_with, use_actor)
	end
	use_actor = use_actor or game.player
	compare_with = compare_with or {}
	local is_orcs = game:isAddonActive("orcs")
	local desc = tstring{}
	
	-- item tier
	if self.material_level then desc:add({"color", "ORANGE"},"T", tostring(self.material_level),{"color", "LAST"}," ") end
	-- item type
	local item_type = tostring(rawget(self, 'type') or "unknown")
	local item_subtype = tostring(rawget(self, 'subtype') or "unknown")
	if item_type == item_subtype then
		desc:add(("%s"):format(item_type))
	else
		desc:add(("%s %s%s"):format( item_subtype, 
																 item_type == "weapon" and  ( self.slot_forbid == "OFFHAND" and "2H " or "1H " ) or "", 
																 item_type) )
	end
	desc:add(true)
	
	-- Requirements
	local reqs = self:getRequirementDesc(use_actor)
	if reqs then
		desc:merge(reqs)
	end
	
	-- item quality
	if self.quest then desc:add({"color", "VIOLET"},"[Plot Item]", {"color", "LAST"}, true)
	elseif self.cosmetic then desc:add({"color", "C578C6"},"[Cosmetic Item]", {"color", "LAST"}, true)
	elseif self.unique then
		if self.legendary then desc:add({"color", "FF4000"},"[Legendary]", {"color", "LAST"}, true)
		elseif self.godslayer then desc:add({"color", "AAD500"},"[Godslayer]", {"color", "LAST"}, true)
		elseif self.randart then desc:add({"color", "FF7700"},"[Random Unique]", {"color", "LAST"}, true)
		else desc:add({"color", "FFD700"},"[Unique]", {"color", "LAST"}, true)
		end
	elseif self.rare then desc:add({"color", "SALMON"},"[Rare]", {"color", "LAST"}, true)
	elseif self.egoed then 
		if self.greater_ego and self.greater_ego > 1 then desc:add({"color", "8d55ff"},"[Ego++]", {"color", "LAST"}, true)
		elseif self.greater_ego then desc:add({"color", "0080FF"},"[Ego+]", {"color", "LAST"}, true)
		else desc:add({"color", "00FF80"},"[Ego]", {"color", "LAST"}, true)
		end 
	else desc:add({"color", "FFFFFF"},"[Normal]", {"color", "LAST"}, true)
	end
	
	-- Power source
	local bHasPower = nil
	if self.power_source then
		if self.power_source.arcane then desc:add( bHasPower and "/" or "",{"color", "VIOLET"}, "Arcane", {"color", "LAST"}) bHasPower = 1 end
		if self.power_source.nature then desc:add( bHasPower and "/" or "",{"color", "OLIVE_DRAB"}, "Nature", {"color", "LAST"}) bHasPower = 1 end
		if self.power_source.antimagic then desc:add( bHasPower and "/" or "",{"color", "ORCHID"}, "Disrupt", {"color", "LAST"}) bHasPower = 1 end
		if self.power_source.technique then desc:add( bHasPower and "/" or "",{"color", "LIGHT_UMBER"}, "Master", {"color", "LAST"}) bHasPower = 1 end
		if self.power_source.psionic then desc:add( bHasPower and "/" or "",{"color", "YELLOW"}, "Psionic", {"color", "LAST"}) bHasPower = 1 end
		if self.power_source.unknown then desc:add( bHasPower and "/" or "",{"color", "CRIMSON"}, "Unknown", {"color", "LAST"}) bHasPower = 1 end
		self:triggerHook{"Object:descPowerSource", desc=desc, object=self}
		desc:add(true)
	end
	desc:add(true)

	if not self:isIdentified() then -- give limited information if the item is unidentified
		local combat = self.combat
		if not combat and self.wielded then
			-- shield combat
			if self.subtype == "shield" and self.special_combat and ((use_actor:knowTalentType("technique/shield-offense") or use_actor:knowTalentType("technique/shield-defense") or use_actor:attr("show_shield_combat") or config.settings.tome.display_shield_stats)) then
				combat = self.special_combat
			end
			-- gloves combat
			if self.subtype == "hands" and self.wielder and self.wielder.combat and (use_actor:knowTalent(use_actor.T_EMPTY_HAND) or use_actor:attr("show_gloves_combat") or config.settings.tome.display_glove_stats) then
				combat = self.wielder.combat
			end
		end
		if combat then -- always list combat damage types (but not amounts)
			local special = 0
			if combat.talented then
				local t = use_actor:combatGetTraining(combat)
				if t and t.name then desc:add("Mastery: ", {"color","GOLD"}, t.name, {"color","LAST"}, true) end
			end
			self:descAccuracyBonus(desc, combat or {}, use_actor)
			if combat.wil_attack then
				desc:add("Accuracy is based on willpower for this weapon.", true)
			end
			local dt = DamageType:get(combat.damtype or DamageType.PHYSICAL)
			desc:add("Weapon Damage: ", dt.text_color or "#WHITE#", dt.name:upper(),{"color","LAST"})
			for dtyp, val in pairs(combat.melee_project or combat.ranged_project or {}) do
				dt = DamageType:get(dtyp)
				if dt then
					if dt.tdesc then
						special = special + 1
					else
						desc:add(", ", dt.text_color or "#WHITE#", dt.name, {"color", "LAST"})
					end
				end
			end
			desc:add(true)
			--special_on_hit count # for both melee and ranged
			if special>0 or combat.special_on_hit or combat.special_on_crit or combat.special_on_kill or combat.burst_on_crit or combat.burst_on_hit or combat.talent_on_hit or combat.talent_on_crit then
				desc:add({"color", mod_PASS_PWR_COLOR},"It can cause special effects when it strikes in combat.",{"color", "LAST"}, true)
			end
			if self.on_block then
				desc:add({"color", mod_PASS_PWR_COLOR},"It can cause special effects when a melee attack is blocked.",{"color", "LAST"}, true)
			end
		end
		if self.wielder then
			if self.wielder.lite then
				desc:add(("It %s ambient light (%+d radius)."):format(self.wielder.lite >= 0 and "provides" or "dims", self.wielder.lite), true)
			end
		end
		if self.wielded then
			if self.use_power or self.use_simple or self.use_talent then
				desc:add("#ORANGE#It has an activatable power.#LAST#", true)
			end
		end
		--desc:add("----END UNIDED DESC----", true)
		return desc
	end

	if self.set_list then
		if self.set_desc then
			for set_id, text in pairs(self.set_desc) do
				desc:add({"color","GREEN"}, text, {"color","LAST"}, true)
			end
		else desc:add({"color","GREEN"}, "A part of set.", {"color","LAST"}, true)
		end
		if self.set_complete then desc:add({"color","LIGHT_GREEN"}, "The set is complete.", {"color","LAST"}, true) end
		desc:add(true)
	end

	local compare_fields = function(item1, items, infield, field, outformat, text, mod, isinversed, isdiffinversed, add_table)
		local add = self:compareFields(item1, items, infield, field, outformat, text, mod, isinversed, isdiffinversed, add_table)
		if add then desc:merge(add) end
	end

	-- included - if we should include the value in the present total.
	-- total_call - function to call on the actor to get the current total
	local compare_scaled = function(item1, items, infield, change_field, results, outformat, text, included, mod, isinversed, isdiffinversed, add_table)
		local out = function(base_change, base_change2)
			local unworn_base = (item1.wielded and table.get(item1, infield, change_field)) or table.get(items, 1, infield, change_field)  -- ugly
			unworn_base = unworn_base or 0
			local scale_change = use_actor:getAttrChange(change_field, -unworn_base, base_change - unworn_base, unpack(results))
			if base_change2 then
				scale_change = scale_change - use_actor:getAttrChange(change_field, -unworn_base, base_change2 - unworn_base, unpack(results))
				base_change = base_change - base_change2
			end
			return outformat:format(base_change, scale_change)
		end
		return compare_fields(item1, items, infield, change_field, out, text, mod, isinversed, isdiffinversed, add_table)
	end

	local compare_table_fields = function(item1, items, infield, field, outformat, text, kfunct, mod, isinversed, filter)
		local ret = self:compareTableFields(item1, items, infield, field, outformat, text, kfunct, mod, isinversed, filter)
		if ret then desc:merge(ret) end
	end
	
	local talent_on_ability_desc = function( s_power, s_desc_pwr )
		local talents = {}
		local ret = tstring{}
		if self[s_power] then
			for _, data in ipairs(self[s_power]) do
				if data and data.talent then	
					talents[data.talent] = {data.chance, data.level}
				end
			end
		end
		for i, v in ipairs(compare_with or {}) do
			for _, data in ipairs(v[field] and (v[field][s_power] or {})or {}) do
				local tid = data.talent
				if not talents[tid] or talents[tid][1]~=data.chance or talents[tid][2]~=data.level then
					ret:add({"color","RED"}, "On ", s_desc_pwr,
						(" #LIGHT_GREEN#%d%%#LAST# %s level #LIGHT_GREEN#%d#LAST#"):format(data.chance, self:getTalentFromId(tid).name, data.level), 
						{"color","WHITE"}, true)
				else
					talents[tid][3] = true
				end
			end
		end
		for tid, data in pairs(talents) do
			ret:add(talents[tid][3] and {"color","WHITE"} or {"color","GREEN"}, "On ", s_desc_pwr,
							(" #LIGHT_GREEN#%d%%#LAST# %s level #LIGHT_GREEN#%d#LAST#"):format(talents[tid][1],self:getTalentFromId(tid).name, talents[tid][2]), 
							{"color","WHITE"}, true)
		end
		return ret
	end

	local desc_combat = function(...)
		local cdesc = self:descCombat(use_actor, ...)
		desc:merge(cdesc)
	end
	
	local desc_wielder = function(w, compare_with, field)
		w = w or {}
		w = w[field] or {}
		
		compare_table_fields(w, compare_with, field, "inc_stats", "%+d", "#ORANGE#" .. mod_align_stat( "Stats" ) .. "#LAST#", function(item)
													 return (" #ORANGE#%s#LAST#"):format(Stats.stats_def[item].short_name:capitalize())
		end)
		if not (self.alchemist_bomb or self.type == "gem") then
			desc:add( mod_DPS_sep,true )    
		end
		compare_fields(w, compare_with, field, "combat_physcrit", "%+.1f%%", mod_align_stat( "Physical Crit" ))
		if is_orcs then
			compare_fields(w, compare_with, field, "combat_steamcrit", "%+d%%", mod_align_stat( "Steam Crit"))
		end
		compare_fields(w, compare_with, field, "combat_spellcrit", "%+d%%", mod_align_stat( "Spell Crit"))
		compare_fields(w, compare_with, field, "combat_mindcrit", "%+d%%", mod_align_stat( "Mind Crit"))
		compare_fields(w, compare_with, field, "combat_critical_power", "%+.2f%%", mod_align_stat( "Critical power" ) )
		compare_scaled(w, compare_with, field, "combat_dam", {"combatPhysicalpower"}, "%+d #LAST#(%+d eff.)", mod_align_stat( "Physical Power" ))
		if is_orcs then
			compare_scaled(w, compare_with, field, "combat_steampower", {"combatSteampower"}, "%+d #LAST#(%+d eff.)", mod_align_stat( "Steampower"))
		end
		compare_scaled(w, compare_with, field, "combat_spellpower", {"combatSpellpower"}, "%+d #LAST#(%+d eff.)", mod_align_stat( "Spellpower"))
		compare_scaled(w, compare_with, field, "combat_mindpower", {"combatMindpower"}, "%+d #LAST#(%+d eff.)", mod_align_stat( "Mindpower"))
		compare_fields(w, compare_with, field, "spellsurge_on_crit", "%+d", mod_align_stat( "Spellpower/crit") )
		-- Speed mod
		compare_fields(w, compare_with, field, "global_speed_add", "%+d%%", mod_align_stat( "Global Speed"), 100)
		compare_fields(w, compare_with, field, "movement_speed", "%+d%%", mod_align_stat( "Move Speed"), 100)
		compare_fields(w, compare_with, field, "combat_physspeed", "%+d%%", mod_align_stat( "Combat Speed"), 100)
		if is_orcs then
			compare_fields(w, compare_with, field, "combat_steamspeed", "%+d%%", mod_align_stat( "Steam Speed"), 100)
		end
		compare_fields(w, compare_with, field, "combat_spellspeed", "%+d%%", mod_align_stat( "Spell Speed"), 100)
		compare_fields(w, compare_with, field, "combat_mindspeed", "%+d%%", mod_align_stat( "Mind Speed"), 100)
		
		local dt_string = tstring{}
		local found = false
		local combat2 = { melee_project = {} }
		for i, v in pairs(w.melee_project or {}) do
			local def = DamageType.dam_def[i]
			if def and def.tdesc then
				local d = def.tdesc(v, nil, use_actor)
				found = true
				dt_string:add({"color","GREEN"},d:gsub("#LAST#","#GREEN#"), {"color","WHITE"}, true)
			else
				combat2.melee_project[i] = v
			end
		end
		
		local ranged = tstring{}
		local ranged_found = false
		local ranged_combat = { ranged_project = {} }
		for i, v in pairs(w.ranged_project or {}) do
			local def = DamageType.dam_def[i]
			if def and def.tdesc then
				local d = def.tdesc(v, nil, use_actor)
				ranged_found = true
				ranged:add({"color","GREEN"},d:gsub("#LAST#","#GREEN#"), {"color","WHITE"}, true)
			else
				ranged_combat.ranged_project[i] = v
			end
		end
		
		compare_table_fields(combat2, compare_with, field, "melee_project", "%d", mod_align_stat( "On-Hit" ), function(item)
													 local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
													 return col[2],mod_eff_name( (" %s"):format(DamageType.dam_def[item].name)),{"color","LAST"}
		end)

		compare_table_fields(ranged_combat, compare_with, field, "ranged_project", "%d", mod_align_stat( "On-Ranged-Hit" ), function(item)
													 local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
													 return col[2],mod_eff_name( (" %s"):format(DamageType.dam_def[item].name) ),{"color","LAST"}
		end)      
		
		compare_table_fields(w, compare_with, field, "inc_damage", "%+d%%", mod_align_stat( "Damage" ), function(item)
													 local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
													 return col[2], (" %s"):format(item == "all" and "all" or (DamageType.dam_def[item] and DamageType.dam_def[item].name or "??")), {"color","LAST"}
		end)
		compare_table_fields(w, compare_with, field, "resists_pen", "%+d%%", mod_align_stat( "Ignore resists" ), function(item)
													 local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
													 return col[2], (" %s"):format(item == "all" and "all" or (DamageType.dam_def[item] and DamageType.dam_def[item].name or "??")), {"color","LAST"}
		end)
		compare_fields(w, compare_with, field, "damage_shield_penetrate", "%+d%%", mod_align_stat( "Ignore Shields"))
		
		compare_table_fields(w, compare_with, field, "inc_damage_actor_type", "%+d%% ", mod_align_stat( "Against" ), function(item)
													 local _, _, t, st = item:find("^([^/]+)/?(.*)$")
													 if st and st ~= "" then
														 return st:capitalize()
													 else
														 return t:capitalize()
													 end
		end)
		compare_scaled(w, compare_with, field, "combat_atk", {"combatAttack"}, "%+d #LAST#(%+d eff.)", mod_align_stat( "Accuracy" ))
		compare_fields(w, compare_with, field, "combat_apr", "%+d", mod_align_stat( "Ignore Armor" ))
		
		local onhit = tstring{}
		local onhit_found = false
		local onhit_combat = { on_melee_hit = {} }
		for i, v in pairs(w.on_melee_hit or {}) do
			local def = DamageType.dam_def[i]
			if def and def.tdesc then
				local d = def.tdesc(v, nil, use_actor)
				onhit_found = true
				onhit:add(d, true)
			else
				onhit_combat.on_melee_hit[i] = v
			end
		end
		
		-- get_items takes the object table and returns a table of items to print.
		-- Each of these items one of the following:
		-- id -> {priority, string}
		-- id -> {priority, message_function(this, compared), value}
		-- header is the section header.
		local compare_list = function(header, get_items)
			local priority_ordering = function(left, right)
				return left[2][1] < right[2][1]
			end

			if next(compare_with) then
				-- Grab the left and right items.
				local left = get_items(self)
				local right = {}
				for i, v in ipairs(compare_with) do
					for k, item in pairs(get_items(v[field])) do
						if not right[k] then
							right[k] = item
						elseif type(right[k]) == 'number' then
							right[k] = right[k] + item
						else
							right[k] = item
						end
					end
				end
				if not left then game.log("No left") end
				if not right then game.log("No right") end
				-- Exit early if no items.
				if not next(left) and not next(right) then return end

				desc:add(header, true)

				local combined = table.clone(left)
				table.merge(combined, right)

				for k, _ in table.orderedPairs2(combined, priority_ordering) do
					l = left[k]
					r = right[k]

					message = (l and l[2]) or (r and r[2])
					if type(message) == 'function' then
						desc:add(message(l and l[3], r and r[3] or 0), true)
					elseif type(message) == 'string' then
						local prefix = '* '
						local color = 'WHITE'
						if l and not r then
							color = 'GREEN'
							prefix = '+ '
						end
						if not l and r then
							color = 'RED'
							prefix = '- '
						end
						desc:add({'color',color}, prefix, message, {'color','LAST'}, true)
					end
				end
			else
				local items = get_items(self)
				if next(items) then
					desc:add(header, true)
					for k, v in table.orderedPairs2(items, priority_ordering) do
						message = v[2]
						if type(message) == 'function' then
							desc:add(message(v[3]), true)
						elseif type(message) == 'string' then
							desc:add({'color','WHITE'}, '* ', message, {'color','LAST'}, true)
						end
					end
				end
			end
		end

		local get_special_list = function(o, key)
			local special = o[key]

			-- No special
			if not special then return {} end
			-- Single special
			if special.desc then
				return {[special.desc] = {10, util.getval(special.desc, self, use_actor, special)}}
			end

			-- Multiple specials
			local list = {}
			for _, special in pairs(special) do
				list[special.desc] = {10, util.getval(special.desc, self, use_actor, special)}
			end
			return list
		end

		compare_list(
			"#YELLOW#On shield block:#LAST#",
			function(o)
				if not o then return {} end
				return get_special_list(o, 'on_block')
			end
		)
		
		compare_table_fields(onhit_combat, compare_with, field, "on_melee_hit", "%d", mod_align_stat( "When Hit" ), function(item)
													 local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
													 return col[2],mod_eff_name( (" %s"):format(DamageType.dam_def[item].name ) ),{"color","LAST"}
		end)
		
		if found then
			desc:add({"color","GREEN"}, "On-Hit (Melee):", {"color","LAST"}, true)
			desc:merge(dt_string)
		end
		
		if ranged_found then
			desc:add({"color","GREEN"}, "On-Hit (Ranged):", {"color","LAST"}, true)
			desc:merge(ranged)
		end
		
		if onhit_found then
			desc:add("#GREEN#When Hit:", true)
			desc:merge(onhit)
			desc:add( "#WHITE#" )
		end
		
		if desc[#desc-1] == mod_DPS_sep then
			desc[#desc] = ""
			desc[#desc-1] = ""
		end
		if not (self.alchemist_bomb or self.type == "gem") then
			desc:add( mod_DEF_sep,true )
		end
		compare_fields(w, compare_with, field, "combat_armor", "%+d", mod_align_stat( "Armor" ))
		compare_fields(w, compare_with, field, "combat_armor_hardiness", "%+d%%", mod_align_stat( "Hardiness" ))
		compare_scaled(w, compare_with, field, "combat_def", {"combatDefense", true}, "%+d #LAST#(%+d eff.)", mod_align_stat( "Defense" ))
		compare_scaled(w, compare_with, field, "combat_def_ranged", {"combatDefenseRanged", true}, "%+d #LAST#(%+d eff.)", mod_align_stat( "Ranged Defense" ))
		compare_fields(w, compare_with, field, "fatigue", "%+d%%", mod_align_stat( "Fatigue" ), 1, true, true)

		--		desc:add({"color","ORANGE"}, "General effects: ", {"color","LAST"}, true)

		compare_table_fields(
			w, compare_with, field,
			"resists", "%+d%%", mod_align_stat( "Resistance" ),
			function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):format(item == "all" and "all" or (DamageType.dam_def[item] and DamageType.dam_def[item].name or "??")), {"color","LAST"}
		end)
		compare_table_fields(
			w, compare_with, field,
			"resists_cap", "%+d%%", mod_align_stat( "Max Resistance" ),
			function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):format(item == "all" and "all" or (DamageType.dam_def[item] and DamageType.dam_def[item].name or "??")), {"color","LAST"}
		end)
		compare_table_fields(
			w, compare_with, field,
			"flat_damage_armor", "%+d", mod_align_stat( "Damage Reduction" ),
			function(item)
				local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
				return col[2], (" %s"):format(item == "all" and "all" or (DamageType.dam_def[item] and DamageType.dam_def[item].name or "??")), {"color","LAST"}
		end)

		compare_fields(w, compare_with, field, "ignore_direct_crits", "%-.2f%%", mod_align_stat( "Crit Resistance") )
		compare_fields(w, compare_with, field, "combat_crit_reduction", "%-d%%", mod_align_stat( "Crit Avoidance" ) )
		-- Evasion
		compare_fields(w, compare_with, field, "projectile_evasion", "%+d%%", mod_align_stat( "Deflect Projectile"))
		compare_fields(w, compare_with, field, "evasion", "%+d%%", mod_align_stat( "Evasion"))
		compare_fields(w, compare_with, field, "cancel_damage_chance", "%+d%%", mod_align_stat( "Damage Avoidance"))
		compare_fields(w, compare_with, field, "damage_resonance", "%+d%%", mod_align_stat( "Resonance"))
		compare_fields(w, compare_with, field, "shield_dur", "%+d", mod_align_stat( "Shield Duration"))
		compare_fields(w, compare_with, field, "shield_factor", "%+d%%", mod_align_stat( "Shield Power"))
		compare_fields(w, compare_with, field, "shield_windwall", "%+d", mod_align_stat("Windwall"))
		
		compare_table_fields(w, compare_with, field, "resists_actor_type", "%+d%% ", mod_align_stat( "Resist Against" ), function(item)
													 local _, _, t, st = item:find("^([^/]+)/?(.*)$")
													 if st and st ~= "" then
														 return st:capitalize()
													 else
														 return t:capitalize()
													 end
		end)
		
		compare_table_fields(w, compare_with, field, "talents_mastery_bonus", "+%0.2f ", mod_align_stat( "Category Bonus" ), function(item)
													 local _, _, t, st = item:find("^([^/]+)/?(.*)$")
													 if st and st ~= "" then
														 return st:capitalize()
													 else
														 return t:capitalize()
													 end
		end)

		compare_table_fields(w, compare_with, field, "damage_affinity", "%+d%%", mod_align_stat( "Affinity" ), function(item)
													 local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
													 return col[2], (" %s"):format(item == "all" and "all" or (DamageType.dam_def[item] and DamageType.dam_def[item].name or "??")), {"color","LAST"}
		end)
		
		compare_scaled(w, compare_with, field, "combat_physresist", {"combatPhysicalResist", true}, "%+d #LAST#(%+d eff.)", mod_align_stat( "Physical save"))
		compare_scaled(w, compare_with, field, "combat_spellresist", {"combatSpellResist", true}, "%+d #LAST#(%+d eff.)", mod_align_stat( "Spell save"))
		compare_scaled(w, compare_with, field, "combat_mentalresist", {"combatMentalResist", true}, "%+d #LAST#(%+d eff.)", mod_align_stat( "Mind save"))
		
		compare_fields(w, compare_with, field, "iceblock_pierce", "%+d%%", mod_align_stat( "Pierce Iceblocks"))
		compare_fields(w, compare_with, field, "slow_projectiles", "%+d%%", mod_align_stat( "Slow Projectiles"))
		compare_fields(w, compare_with, field, "resist_unseen", "%-d%%", mod_align_stat( "Resist unseen"))
		compare_fields(w, compare_with, field, "paradox_reduce_anomalies", "%+d", mod_align_stat( "Anomaly Control"))
		compare_fields(w, compare_with, field, "inc_stealth", "%+d", mod_align_stat( "Stealth" ) )
		compare_fields(w, compare_with, field, "invisible", "%+d", mod_align_stat( "Invisibility"))
		
		-- Heal/HP
		compare_fields(w, compare_with, field, "die_at", "%+.2f life", mod_align_stat( "Unlife"), 1, true, true)
		compare_fields(w, compare_with, field, "max_life", "%+.2f", mod_align_stat( "Life"))
		compare_fields(w, compare_with, field, "life_regen", "%+.2f", mod_align_stat( "Life Regen" ))
		compare_fields(w, compare_with, field, "healing_factor", "%+d%%", mod_align_stat( "Healmod"), 100)
		compare_fields(w, compare_with, field, "life_leech_chance", "%+d%%", mod_align_stat( "Lifesteal Chance"))
		compare_fields(w, compare_with, field, "life_leech_value", "%+d%%", mod_align_stat( "Lifesteal"))
		compare_fields(w, compare_with, field, "heal_on_nature_summon", "%+d", mod_align_stat( "Heal-on-summon"))
		-- immunities
		compare_fields(w, compare_with, field, "blind_immune", "%+d%%", mod_align_stat( "Blind Resist" ), 100)
		compare_fields(w, compare_with, field, "poison_immune", "%+d%%", mod_align_stat( "Poison Resist" ), 100)
		compare_fields(w, compare_with, field, "disease_immune", "%+d%%", mod_align_stat( "Disease Resist" ), 100)
		compare_fields(w, compare_with, field, "cut_immune", "%+d%%", mod_align_stat( "Cut Resist" ), 100)
		compare_fields(w, compare_with, field, "silence_immune", "%+d%%", mod_align_stat( "Silence Resist" ), 100)
		compare_fields(w, compare_with, field, "disarm_immune", "%+d%%", mod_align_stat( "Disarm Resist" ), 100)
		compare_fields(w, compare_with, field, "confusion_immune", "%+d%%", mod_align_stat( "Confus Resist" ), 100)
		compare_fields(w, compare_with, field, "sleep_immune", "%+d%%", mod_align_stat( "Sleep Resist" ), 100)
		compare_fields(w, compare_with, field, "pin_immune", "%+d%%", mod_align_stat( "Pinning Resist" ), 100)
		compare_fields(w, compare_with, field, "stun_immune", "%+d%%", mod_align_stat( "Stun Resist" ), 100)
		compare_fields(w, compare_with, field, "fear_immune", "%+d%%", mod_align_stat( "Fear Resist" ), 100)
		compare_fields(w, compare_with, field, "knockback_immune", "%+d%%", mod_align_stat( "Knockbk Resist" ), 100)
		compare_fields(w, compare_with, field, "instakill_immune", "%+d%%", mod_align_stat( "Instkill Resist"), 100)
		compare_fields(w, compare_with, field, "teleport_immune", "%+d%%", mod_align_stat( "Teleport Resist" ), 100)
		
		-- Teleport
		compare_fields(w, compare_with, field, "defense_on_teleport", "%+d", mod_align_stat( "Out-of-Phase Defense"))
		compare_fields(w, compare_with, field, "resist_all_on_teleport", "%+d%%", mod_align_stat( "Out-of-Phase Resistance"))
		compare_fields(w, compare_with, field, "effect_reduction_on_teleport", "%+d%%", mod_align_stat( "Out-of-Phase Resilience"))
		
		if desc[#desc-1] == mod_DEF_sep then
			desc[#desc] = ""
			desc[#desc-1] = ""
		end
		if not (self.alchemist_bomb or self.type == "gem") then
			desc:add( mod_MISC_sep,true )
		end
		compare_fields(w, compare_with, field, "ammo_reload_speed", "%+d", mod_align_stat( "Reload" ))
		compare_fields(w, compare_with, field, "disarm_bonus", "%+d", mod_align_stat( "Disarm Traps" ) )
		compare_fields(w, compare_with, field, "max_encumber", "%+d", mod_align_stat( "Encumbrance" ) )
		--
		compare_fields(w, compare_with, field, "stamina_regen", "%+.2f", mod_align_stat( "Stamina/turn" ))
		if is_orcs then
			compare_fields(w, compare_with, field, "steam_regen", "%+.2f", mod_align_stat( "Steam/turn"))
		end
		compare_fields(w, compare_with, field, "mana_regen", "%+.2f", mod_align_stat( "Mana/turn") )
		compare_fields(w, compare_with, field, "hate_regen", "%+.2f", mod_align_stat( "Hate/turn") )
		compare_fields(w, compare_with, field, "psi_regen", "%+.2f", mod_align_stat( "Psi/turn") )
		compare_fields(w, compare_with, field, "equilibrium_regen", "%+.2f", mod_align_stat( "EQ/turn" ), nil, true, true)
		compare_fields(w, compare_with, field, "vim_regen", "%+.2f", mod_align_stat( "Vim/turn") )
		compare_fields(w, compare_with, field, "positive_regen", "%+.2f", mod_align_stat( "Positive/turn") )
		compare_fields(w, compare_with, field, "negative_regen", "%+.2f", mod_align_stat( "Negative/turn") )

		compare_fields(w, compare_with, field, "stamina_regen_when_hit", "%+.2f", mod_align_stat( "Stamina when Hit") )
		compare_fields(w, compare_with, field, "mana_regen_when_hit", "%+.2f", mod_align_stat( "Mana when Hit") )
		compare_fields(w, compare_with, field, "equilibrium_regen_when_hit", "%+.2f", mod_align_stat( "EQ when Hit"))
		compare_fields(w, compare_with, field, "psi_regen_when_hit", "%+.2f", mod_align_stat( "Psi when Hit"))
		compare_fields(w, compare_with, field, "hate_regen_when_hit", "%+.2f", mod_align_stat( "Hate when Hit"))
		compare_fields(w, compare_with, field, "vim_regen_when_hit", "%+.2f", mod_align_stat( "Vim when Hit"))

		compare_fields(w, compare_with, field, "vim_on_melee", "%+.2f", mod_align_stat( "Vim-on-Hit") )

		compare_fields(w, compare_with, field, "mana_on_crit", "%+.2f", mod_align_stat( "Mana-on-crit" ))
		compare_fields(w, compare_with, field, "vim_on_crit", "%+.2f", mod_align_stat( "Vim-on-crit"))


		compare_fields(w, compare_with, field, "hate_on_crit", "%+.2f", mod_align_stat( "Hate-on-crit"))
		compare_fields(w, compare_with, field, "psi_on_crit", "%+.2f", mod_align_stat( "Psi-on-crit"))
		compare_fields(w, compare_with, field, "equilibrium_on_crit", "%+.2f", mod_align_stat( "EQ-on-crit"))

		compare_fields(w, compare_with, field, "hate_per_kill", "+%0.2f", mod_align_stat( "Hate/kill"))
		compare_fields(w, compare_with, field, "psi_per_kill", "+%0.2f", mod_align_stat( "Psi/kill"))
		compare_fields(w, compare_with, field, "vim_on_death", "%+.2f", mod_align_stat( "Vim/kill"))

		compare_fields(w, compare_with, field, "max_mana", "%+.2f", mod_align_stat( "Max mana"))
		compare_fields(w, compare_with, field, "max_soul", "%+.2f", mod_align_stat( "Max souls"))
		compare_fields(w, compare_with, field, "max_stamina", "%+.2f", mod_align_stat( "Max stamina"))
		if is_orcs then
			compare_fields(w, compare_with, field, "max_steam", "%+.2f", mod_align_stat( "Max steam"))
		end
		compare_fields(w, compare_with, field, "max_hate", "%+.2f", mod_align_stat( "Max hate"))
		compare_fields(w, compare_with, field, "max_psi", "%+.2f", mod_align_stat( "Max psi"))
		compare_fields(w, compare_with, field, "max_vim", "%+.2f", mod_align_stat( "Max vim"))
		compare_fields(w, compare_with, field, "max_positive", "%+.2f", mod_align_stat( "Max positive"))
		compare_fields(w, compare_with, field, "max_negative", "%+.2f", mod_align_stat( "Max negative"))
		compare_fields(w, compare_with, field, "max_air", "%+.2f", mod_align_stat( "Max air"))
		
		compare_fields(w, compare_with, field, "spell_cooldown_reduction", "%d%%", mod_align_stat( "Spell cooldown"), 100)
		
		compare_fields(w, compare_with, field, "lite", "%+d", mod_align_stat( "Light"))
		compare_fields(w, compare_with, field, "infravision", "%+d", mod_align_stat( "Infravision"))
		compare_fields(w, compare_with, field, "heightened_senses", "%+d", mod_align_stat( "Heightened Senses"))
		compare_fields(w, compare_with, field, "sight", "%+d", mod_align_stat( "Sight"))

		compare_fields(w, compare_with, field, "see_stealth", "%+d", mod_align_stat( "See Stealth"))

		compare_fields(w, compare_with, field, "see_invisible", "%+d", mod_align_stat( "See Invis"))
		compare_table_fields(w, compare_with, field, "wards", "%+d", mod_align_stat( "Wards" ), function(item)
													 local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
													 return col[2], (" %s"):format(item == "all" and "all" or (DamageType.dam_def[item] and DamageType.dam_def[item].name or "??")), {"color","LAST"}
		end)

		compare_fields(w, compare_with, field, "resource_leech_chance", "%+d%%", mod_align_stat( "Leech Chance"))
		compare_fields(w, compare_with, field, "resource_leech_value", "%+d", mod_align_stat( "Leech"))

		compare_fields(w, compare_with, field, "nature_summon_max", "%+d", mod_align_stat( "Max Summons"))
		compare_fields(w, compare_with, field, "nature_summon_regen", "%+.2f", mod_align_stat( "Summon Regen"))

		compare_fields(w, compare_with, field, "damage_backfire", "%+d%%", mod_align_stat( "Backlash"), nil, true)
		
		compare_fields(w, compare_with, field, "size_category", "%+d", mod_align_stat( "Size"))
		
		local any_esp = false
		local esps_compare = {}
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].esp_all and v[field].esp_all > 0 then
				esps_compare["All"] = esps_compare["All"] or {}
				esps_compare["All"][1] = true
				any_esp = true
			end
			for type, i in pairs(v[field] and (v[field].esp or {}) or {}) do if i and i > 0 then
					local _, _, t, st = type:find("^([^/]+)/?(.*)$")
					local esp = ""
					if st and st ~= "" then
						esp = t:capitalize().."/"..st:capitalize()
					else
						esp = t:capitalize()
					end
					esps_compare[esp] = esps_compare[esp] or {}
					esps_compare[esp][1] = true
					any_esp = true
			end end
		end

		-- Telepathy
		local esps = {}
		if w.esp_all and w.esp_all > 0 then
			esps[#esps+1] = "All"
			esps_compare[esps[#esps]] = esps_compare[esps[#esps]] or {}
			esps_compare[esps[#esps]][2] = true
			any_esp = true
		end
		for type, i in pairs(w.esp or {}) do if i and i > 0 then
				local _, _, t, st = type:find("^([^/]+)/?(.*)$")
				if st and st ~= "" then
					esps[#esps+1] = t:capitalize().."/"..st:capitalize()
				else
					esps[#esps+1] = t:capitalize()
				end
				esps_compare[esps[#esps]] = esps_compare[esps[#esps]] or {}
				esps_compare[esps[#esps]][2] = true
				any_esp = true
		end end
		if any_esp then
			desc:add(mod_align_stat( "Telepathy" ))
			local f_first = true
			for esp, isin in pairs(esps_compare) do
				if not f_first then
					desc:add(mod_align_stat())
				end
				if isin[2] then
					desc:add(isin[1] and {"color","WHITE"} or {"color","GREEN"}, ("%s "):format(esp), {"color","LAST"},true)
				else
					desc:add({"color","RED"}, ("%s "):format(esp), {"color","LAST"},true)
				end
				f_first = false
			end
		end
		-- Telepathy range
		compare_fields(w, compare_with, field, "esp_range", "%+d", mod_align_stat( "Telepath range" ) )

		-- Breathes
		local any_breath = 0
		local breaths = {}
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].can_breath then
				for what, _ in pairs(v[field].can_breath) do
					breaths[what] = breaths[what] or {}
					breaths[what][1] = true
					any_breath = any_breath + 1
				end
			end
		end
		for what, _ in pairs(w.can_breath or {}) do
			breaths[what] = breaths[what] or {}
			breaths[what][2] = true
			any_breath = any_breath + 1
		end
		if any_breath > 0 then
			desc:add(mod_align_stat( "Breathe" ))
			for what, isin in pairs(breaths) do
				if isin[2] then
					desc:add(isin[1] and {"color","WHITE"} or {"color","GREEN"}, ("%s "):format(what), {"color","LAST"})
				else
					desc:add({"color","RED"}, ("%s "):format(what), {"color","LAST"})
				end
			end
			desc:add(true)
		end
		
		-- Display learned talents
		local any_learn_talent = 0
		local learn_talents = {}
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].learn_talent then
				for tid, tl in pairs(v[field].learn_talent) do if tl > 0 then
						learn_talents[tid] = learn_talents[tid] or {}
						learn_talents[tid][1] = tl
						any_learn_talent = any_learn_talent + 1
				end end
			end
		end
		for tid, tl in pairs(w.learn_talent or {}) do if tl > 0 then
				learn_talents[tid] = learn_talents[tid] or {}
				learn_talents[tid][2] = tl
				any_learn_talent = any_learn_talent + 1
		end end
		if any_learn_talent > 0 then
			desc:add(mod_align_stat("Talents"))
			local f_first = true
			for tid, tl in pairs(learn_talents) do
				if not f_first then
					desc:add(mod_align_stat())
				end
				local diff = (tl[2] or 0) - (tl[1] or 0)
				local name = Talents.talents_def[tid].name
				if diff ~= 0 then
					if tl[1] then
						desc:add(("+%d"):format(tl[2] or 0), diff < 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, ("(+%d)"):format(diff), {"color","LAST"}, (" %s"):format(name),true)
					else
						desc:add({"color","LIGHT_GREEN"}, ("+%d"):format(tl[2] or 0),  {"color","LAST"}, (" %s"):format(name),true)
					end
				else
					desc:add({"color","WHITE"}, ("%+.2f(-) %s"):format(tl[2] or tl[1], name), {"color","LAST"},true)
				end
				f_first = false
			end
		end
		
		-- cooldown reduction
		local any_cd_reduction = 0
		local cd_reductions = {}
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].talent_cd_reduction then
				for tid, cd in pairs(v[field].talent_cd_reduction) do
					cd_reductions[tid] = cd_reductions[tid] or {}
					cd_reductions[tid][1] = cd
					any_cd_reduction = any_cd_reduction + 1
				end
			end
		end
		for tid, cd in pairs(w.talent_cd_reduction or {}) do
			cd_reductions[tid] = cd_reductions[tid] or {}
			cd_reductions[tid][2] = cd
			any_cd_reduction = any_cd_reduction + 1
		end
		if any_cd_reduction > 0 then
			desc:add(mod_align_stat("Cooldown"))
			local f_first = true
			for tid, cds in pairs(cd_reductions) do
				if not f_first then
					desc:add(mod_align_stat())
				end
				local diff = (cds[2] or 0) - (cds[1] or 0)
				if diff ~= 0 then
					if cds[1] then
						desc:add(("%s "):format(Talents.talents_def[tid].name), ("%+d"):format(-(cds[2] or 0)), diff < 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, ("(%+d)"):format(-diff), {"color","LAST"},true)
					else
						desc:add(("%s "):format(Talents.talents_def[tid].name), {"color","LIGHT_GREEN"}, ("%+d"):format(-(cds[2] or 0)), {"color","LAST"},true)
					end
				else
					desc:add({"color","WHITE"}, ("%s %+d(-)"):format(Talents.talents_def[tid].name, -(cds[2] or cds[1]), {"color","LAST"}),true)
				end
				f_first = false
			end
		end
		
		-- Masteries
		local any_mastery = 0
		local masteries = {}
		for i, v in ipairs(compare_with or {}) do
			if v[field] and v[field].talents_types_mastery then
				for ttn, mastery in pairs(v[field].talents_types_mastery) do
					masteries[ttn] = masteries[ttn] or {}
					masteries[ttn][1] = mastery
					any_mastery = any_mastery + 1
				end
			end
		end
		for ttn, i in pairs(w.talents_types_mastery or {}) do
			masteries[ttn] = masteries[ttn] or {}
			masteries[ttn][2] = i
			any_mastery = any_mastery + 1
		end
		if any_mastery > 0 then
			desc:add("Masteries",true)
			for ttn, ttid in pairs(masteries) do
				local tt = Talents.talents_types_def[ttn]
				if tt then
					local cat = tt.type:gsub("/.*", "")
					local name = cat:capitalize().."/"..tt.name:capitalize()
					local diff = (ttid[2] or 0) - (ttid[1] or 0)
					if diff ~= 0 then
						if ttid[1] then
							desc:add(("%+.2f"):format(ttid[2] or 0), diff < 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, ("(%+.2f) "):format(diff), {"color","LAST"}, ("%s"):format(name),true)
						else
							desc:add({"color","LIGHT_GREEN"}, ("%+.2f"):format(ttid[2] or 0),  {"color","LAST"}, (" %s "):format(name),true)
						end
					else
						desc:add({"color","WHITE"}, ("%+.2f(-) %s "):format(ttid[2] or ttid[1], name), {"color","LAST"},true)
					end
				end
			end
		end

		self:triggerHook{"Object:descWielder", compare_with=compare_with, compare_fields=compare_fields, compare_scaled=compare_scaled, compare_table_fields=compare_table_fields, desc=desc, w=w, field=field}
		if desc[#desc-1] == mod_MISC_sep then
			desc[#desc] = ""
			desc[#desc-1] = ""
		end
		
		if w.undead and w.undead > 0 then desc:add({"color", "FF4500"},"The wearer is treated as an undead.",{"color", "LAST"}, true) end
		if w.demon and w.demon > 0 then desc:add({"color", "FF4500"},"The wearer is treated as a demon.",{"color", "LAST"},true) end
		if w.blind and w.blind > 0 then desc:add({"color", "FF4500"},"The wearer is blinded.",{"color", "LAST"}, true) end
		if w.sleep and w.sleep > 0 then desc:add({"color", "FF4500"},"The wearer is asleep.",{"color", "LAST"}, true) end

		if w.blind_fight and w.blind_fight > 0 then desc:add({"color", mod_PASS_PWR_COLOR}, "Blind-Fight: No penalty when attacking invisible/stealthed", {"color", "LAST"},  true) end
		if w.lucid_dreamer and w.lucid_dreamer > 0 then desc:add({"color", mod_PASS_PWR_COLOR}, "Lucid Dreamer: ", "May act while sleeping", {"color", "LAST"},  true) end
		if w.no_breath and w.no_breath > 0 then desc:add({"color", mod_PASS_PWR_COLOR},"The wearer no longer has to breathe.",{"color", "LAST"}, true) end
		if w.quick_weapon_swap and w.quick_weapon_swap > 0 then desc:add({"color", mod_PASS_PWR_COLOR}, "Instant Weapon Swap", {"color", "LAST"}, true) end
		if w.avoid_pressure_traps and w.avoid_pressure_traps > 0 then desc:add({"color", mod_PASS_PWR_COLOR}, "Avoid Pressure Traps", {"color", "LAST"}, true) end
		if w.speaks_shertul and w.speaks_shertul > 0 then desc:add({"color", mod_PASS_PWR_COLOR},"May understand old Sher'Tul language.", {"color", "LAST"}, true) end
		
		-- Do not show "general effect" if nothing to show
		--		if desc[#desc-2] == "General effects: " then table.remove(desc) table.remove(desc) table.remove(desc) table.remove(desc) end

		local can_combat_unarmed = false
		local compare_unarmed = {}
		for i, v in ipairs(compare_with) do
			if v.wielder and v.wielder.combat then
				can_combat_unarmed = true
			end
			compare_unarmed[i] = compare_with[i].wielder or {}
		end

		if (w and w.combat or can_combat_unarmed) and (use_actor:knowTalent(use_actor.T_EMPTY_HAND) or use_actor:attr("show_gloves_combat") or config.settings.tome.display_glove_stats) then
			desc:add({"color","YELLOW"}, "Unarmed combat:", {"color", "LAST"}, true)
			compare_tab = { dam=1, atk=1, apr=0, physcrit=0, physspeed =(use_actor:knowTalent(use_actor.T_EMPTY_HAND) and 0.8 or 1), dammod={str=1}, damrange=1.1 }
			desc_combat(w, compare_unarmed, "combat", compare_tab, true)
		elseif (w and w.combat or can_combat_unarmed) then
			desc:add({"color","LIGHT_BLUE"}, "Learn an unarmed attack talent or enable 'Always show glove combat' to see combat stats.", {"color", "LAST"}, true)
		end
	end
	local can_combat = false
	local can_special_combat = false
	local can_wielder = false
	local can_carrier = false
	local can_imbue_powers = false

	for i, v in ipairs(compare_with) do
		if v.combat then
			can_combat = true
		end
		if v.special_combat then
			can_special_combat = true
		end
		if v.wielder then
			can_wielder = true
		end
		if v.carrier then
			can_carrier = true
		end
		if v.imbue_powers then
			can_imbue_powers = true
		end
	end

	if self.combat or can_combat then
		desc_combat(self, compare_with, "combat")
	end

	if (self.special_combat or can_special_combat) and (use_actor:knowTalentType("technique/shield-offense") or use_actor:knowTalentType("technique/shield-defense") or use_actor:attr("show_shield_combat") or config.settings.tome.display_shield_stats) then
		desc:add({"color","YELLOW"}, "When used to Attack:", {"color", "LAST"}, true)
		desc_combat(self, compare_with, "special_combat")
	elseif (self.special_combat or can_special_combat) then
		desc:add({"color","LIGHT_BLUE"}, "Learn shield attack talent or enable 'Always show shield combat' to see combat stats.", {"color", "LAST"}, true)
	end

	if self.no_teleport then
		desc:add({"color","RED"}, "Cannot be teleported.", {"color", "LAST"}, true)
	end

	if self.wielder or can_wielder then
		desc:add({"color","YELLOW"}, "While equipped:", {"color", "LAST"}, true)
		desc_wielder(self, compare_with, "wielder")
		if self:attr("skullcracker_mult") and use_actor:knowTalent(use_actor.T_SKULLCRACKER) then 
			compare_fields(self, compare_with, "wielder", "skullcracker_mult", "%+d", mod_align_stat( "Skullcracker"))
		end
	end

	if self.carrier or can_carrier then
		desc:add({"color","YELLOW"}, "While carried:", {"color", "LAST"}, true)
		desc_wielder(self, compare_with, "carrier")
	end

	if self.is_tinker then
		if self.on_type or self.on_slot then 
			desc:add("Attachable to ", {"color","ORANGE"}, 
							 (self.on_type or self.on_slot):lower(), self.on_subtype and ("/" .. self.on_subtype) or "", 
							 {"color", "LAST"}, true)
		end

		if self.object_tinker and (self.object_tinker.combat or self.object_tinker.wielder) then
			desc:add({"color","YELLOW"}, "When attached:", {"color", "LAST"}, true)
			if self.object_tinker.combat then desc_combat(self.object_tinker, compare_with, "combat") end
			if self.object_tinker.wielder then desc_wielder(self.object_tinker, compare_with, "wielder") end
		end
	end
	
	desc:merge( talent_on_ability_desc( "talent_on_spell", "#PURPLE#Spell#LAST# Hit:" ) )
	desc:merge( talent_on_ability_desc( "talent_on_wild_gift", "#LIGHT_GREEN#Nature#LAST# Hit:" ) )
	desc:merge( talent_on_ability_desc( "talent_on_mind", "#YELLOW#Mind#LAST# Hit:" ) )
	
	if self.special_desc then
		local d = self:special_desc(use_actor)
		if d then
			desc:add({"color", mod_PASS_PWR_COLOR})
			desc:add( mod_hl_values(d) )
			desc:add({"color", "WHITE"}, true)
		end
	end

	if self.on_block and self.on_block.desc then
		local d = self.on_block.desc
		desc:add({"color", mod_PASS_PWR_COLOR})
		desc:add("On block: " .. mod_hl_values(d))
		desc:add({"color", "WHITE"}, true)
	end

	if self.imbue_powers or can_imbue_powers then
		desc:add({"color","YELLOW"}, "Item imbue powers:", {"color", "LAST"}, true)
		desc_wielder(self, compare_with, "imbue_powers")
	end

	if self.alchemist_bomb or self.type == "gem" and use_actor:knowTalent(Talents.T_CREATE_ALCHEMIST_GEMS) then
		local a = self.alchemist_bomb
		if not a then
			a = game.zone.object_list["ALCHEMIST_GEM_"..self.name:gsub(" ", "_"):upper()]
			if a then a = a.alchemist_bomb end
		end
		if a then
			desc:add({"color","YELLOW"}, "When used as an alchemist bomb:", {"color", "LAST"}, true)
			if a.power then desc:add(("Bomb damage +%d%%"):format(a.power), true) end
			if a.range then desc:add(("Bomb thrown range +%d"):format(a.range), true) end
			if a.mana then desc:add(("Mana regain %d"):format(a.mana), true) end
			if a.daze then desc:add(("%d%% chance to daze for %d turns"):format(a.daze.chance, a.daze.dur), true) end
			if a.stun then desc:add(("%d%% chance to stun for %d turns"):format(a.stun.chance, a.stun.dur), true) end
			if a.splash then
				if a.splash.desc then
					desc:add(a.splash.desc, true)
				else
					desc:add(("Additional %d %s damage"):format(a.splash.dam, DamageType:get(DamageType[a.splash.type]).name), true)
				end
			end
			if a.leech then desc:add(("Life regen %d%% of max life"):format(a.leech), true) end
		end
	end

	local latent = table.get(self.color_attributes, 'damage_type')
	if latent then
		latent = DamageType:get(latent) or {}
		desc:add({"color","YELLOW",}, "Latent Damage Type: ", {"color","LAST",},
			latent.text_color or "#WHITE#", latent.name:capitalize(), {"color", "LAST",}, true)
	end
	
	if self.inscription_data and self.inscription_talent then
		use_actor.__inscription_data_fake = self.inscription_data
		local t = self:getTalentFromId("T_"..self.inscription_talent.."_1")
		if t then
			--local ok, tdesc = pcall(use_actor.getTalentFullDescription, use_actor, t, nil)
			local ok, tdesc = pcall(use_actor.getTalentFullDescription, use_actor, t, 0, {ignore_mode=true, ignore_ressources=true, ignore_blank_range=true, ignore_travel_speed=true, ignore_level=true, tooltip_mode = true})-- ,nil,{tooltip_mode=true})
			if ok and tdesc then
				desc:add({"color","YELLOW"}, "When inscribed on your body:", {"color", "LAST"}, true)
				
				desc:merge(tdesc)
				desc:add(true)
			end
		end
		use_actor.__inscription_data_fake = nil
	end

	if self.wielder and self.wielder.talents_add_levels then
		for tid, lvl in pairs(self.wielder.talents_add_levels) do
			local t = use_actor:getTalentFromId(tid)
			desc:add(lvl < 0 and {"color","FIREBRICK"} or {"color","OLIVE_DRAB"}, ("Talent level: %+d %s."):tformat(lvl, t and t.name or "???"), {"color","LAST"}, true)
		end
	end
	if self.talents_add_levels_filters then
		for _, data in ipairs(self.talents_add_levels_filters) do
			desc:add(data.detrimental and {"color","FIREBRICK"} or {"color","OLIVE_DRAB"}, ("Talent level: %s."):tformat(data.desc), {"color","LAST"}, true)
		end
	end
	
	self:triggerHook{"Object:descMisc", compare_with=compare_with, compare_fields=compare_fields, compare_scaled=compare_scaled, compare_table_fields=compare_table_fields, desc=desc, object=self}
	
	if self.curse then
		local t = use_actor:getTalentFromId(use_actor.T_DEFILING_TOUCH)
		if t and t.canCurseItem(use_actor, t, self) then
			desc:add({"color",0xf5,0x3c,0xbe}, use_actor.tempeffect_def[self.curse].desc, {"color","LAST"}, true)
		end
	end
	
	local use_desc = self:getUseDesc(use_actor)
	if use_desc then
		if self.wielder or self.combat then desc:add(true) end
		desc:merge(use_desc:toTString())
		desc:add(true)
	end
	
	return desc
end

--- Static
local base_descCombat = _M.descCombat
function _M:descCombat(use_actor, combat, compare_with, field, add_table, is_fake_add)
	if core.key.modState("alt") then
		return base_descCombat(self, use_actor, combat, compare_with, field, add_table, is_fake_add)
	end
	local desc = tstring{}
	add_table = add_table or {}
	add_table.dammod = add_table.dammod or {}
	combat = table.clone(combat[field] or {})
	compare_with = compare_with or {}

	local compare_fields = function(item1, items, infield, field, outformat, text, mod, isinversed, isdiffinversed, add_table)
		local add = self:compareFields(item1, items, infield, field, outformat, text, mod, isinversed, isdiffinversed, add_table)
		if add then desc:merge(add) end
	end
	local compare_table_fields = function(item1, items, infield, field, outformat, text, kfunct, mod, isinversed, filter)
		local add = self:compareTableFields(item1, items, infield, field, outformat, text, kfunct, mod, isinversed, filter)
		if add then desc:merge(add) end
	end
	
	local talent_on_hit_desc = function( s_power, s_desc_pwr )
		local talents = {}
		local ret = tstring{}
		if combat[s_power] then
			for tid, data in pairs(combat[s_power]) do
				talents[tid] = {data.chance, data.level}
			end
		end
		for i, v in ipairs(compare_with or {}) do
			for tid, data in pairs(v[field] and (v[field][s_power] or {})or {}) do
				if not talents[tid] or talents[tid][1]~=data.chance or talents[tid][2]~=data.level then
					ret:add({"color","RED"}, "On ", s_desc_pwr,
						(" #LIGHT_GREEN#%d%%#LAST# %s level #LIGHT_GREEN#%d#LAST#"):format(data.chance, self:getTalentFromId(tid).name, data.level), 
						{"color","WHITE"}, true)
				else
					talents[tid][3] = true
				end
			end
		end
		for tid, data in pairs(talents) do
			ret:add(talents[tid][3] and {"color","WHITE"} or {"color","GREEN"}, "On ", s_desc_pwr,
							(" #LIGHT_GREEN#%d%%#LAST# %s level #LIGHT_GREEN#%d#LAST#"):format(talents[tid][1],self:getTalentFromId(tid).name, talents[tid][2]), 
							{"color","WHITE"}, true)
		end
		return ret
	end

	local dm = {}
	combat.dammod = table.mergeAdd(table.clone(combat.dammod or {}), add_table.dammod)
	local dammod = use_actor:getDammod(combat)
	for stat, i in pairs(dammod) do
		local name = Stats.stats_def[stat].short_name:capitalize()
		if use_actor:knowTalent(use_actor.T_STRENGTH_OF_PURPOSE) then
			if name == "Str" then name = "Mag" end
		end
		if self.subtype == "dagger" and use_actor:knowTalent(use_actor.T_LETHALITY) then
			if name == "Str" then name = "Cun" end
		end
		dm[#dm+1] = ("%d%% %s"):format(i * 100, name)
	end
	if #dm > 0 or combat.dam then
		local diff_count = 0
		local any_diff = false
		if config.settings.tome.advanced_weapon_stats then
			local base_power = use_actor:combatDamagePower(combat, add_table.dam)
			local base_range = use_actor:combatDamageRange(combat, add_table.damrange)
			local power_diff, range_diff = {}, {}
			for _, v in ipairs(compare_with) do
				if v[field] then
					local base_power_diff = base_power - use_actor:combatDamagePower(v[field], add_table.dam)
					local base_range_diff = base_range - use_actor:combatDamageRange(v[field], add_table.damrange)
					power_diff[#power_diff + 1] = ("%s%+d%%#LAST#"):format(base_power_diff > 0 and "#00ff00#" or "#ff0000#", base_power_diff * 100)
					range_diff[#range_diff + 1] = ("%s%+.1fx#LAST#"):format(base_range_diff > 0 and "#00ff00#" or "#ff0000#", base_range_diff)
					diff_count = diff_count + 1
					if base_power_diff ~= 0 or base_range_diff ~= 0 then
						any_diff = true
					end
				end
			end
			if any_diff then
				local s = ( mod_align_stat( "Weapon Damage",-1 ) .. "%3d%% (%s)  Range: 1.0x-%.1fx (%s)"):format(base_power * 100, table.concat(power_diff, " / "), base_range, table.concat(range_diff, " / "))
				desc:merge(s:toTString())
			else
				desc:add(( mod_align_stat( "Weapon Damage",-1 ) .. "%3d%%  Range: 1.0x-%.1fx"):format(base_power * 100, base_range))
			end
		else
			local power_diff = {}
			for i, v in ipairs(compare_with) do
				if v[field] then
					local base_power_diff = ((combat.dam or 0) + (add_table.dam or 0)) - ((v[field].dam or 0) + (add_table.dam or 0))
					local dfl_range = (1.1 - (add_table.damrange or 0))
					local multi_diff = (((combat.damrange or dfl_range) + (add_table.damrange or 0)) * ((combat.dam or 0) + (add_table.dam or 0))) - (((v[field].damrange or dfl_range) + (add_table.damrange or 0)) * ((v[field].dam or 0) + (add_table.dam or 0)))
					power_diff [#power_diff + 1] = ("%s%+.1f#LAST# - %s%+.1f#LAST#"):format(base_power_diff > 0 and "#00ff00#" or "#ff0000#", base_power_diff, multi_diff > 0 and "#00ff00#" or "#ff0000#", multi_diff)
					diff_count = diff_count + 1
					if base_power_diff ~= 0 or multi_diff ~= 0 then
						any_diff = true
					end
				end
			end
			if any_diff == false then
				power_diff = ""
			else
				power_diff = ("(%s)"):format(table.concat(power_diff, " / "))
			end
			desc:add(( mod_align_stat( "Weapon Damage",-1) .. "%.1f - %.1f"):format((combat.dam or 0) + (add_table.dam or 0), ((combat.damrange or (1.1 - (add_table.damrange or 0))) + (add_table.damrange or 0)) * ((combat.dam or 0) + (add_table.dam or 0))))
			desc:merge(power_diff:toTString())
			local col = (combat.damtype and DamageType:get(combat.damtype) and DamageType:get(combat.damtype).text_color or "#WHITE#"):toTString()
			desc:add(" ",col[2],DamageType:get(combat.damtype or DamageType.PHYSICAL).name:capitalize(),{"color","LAST"})
		end
		desc:add(true)
		if #dm <= 3 then
			desc:add(( mod_align_stat( "Uses" ) .. "%s"):format(table.concat(dm, ', ')), true)
		else
			desc:add(( mod_align_stat( "Uses" ) .. "%s"):format(table.concat(dm, ', ', 1, 3 )), true)
			desc:add(( mod_align_stat() .. "%s"):format(table.concat(dm, ', ', 4 )), true)
		end
		if config.settings.tome.advanced_weapon_stats then
			local col = (combat.damtype and DamageType:get(combat.damtype) and DamageType:get(combat.damtype).text_color or "#WHITE#"):toTString()
			desc:add( mod_align_stat( "Damage" ), col[2],DamageType:get(combat.damtype or DamageType.PHYSICAL).name:capitalize(),{"color","LAST"}, true)
		end
	end

	if combat.talented then
		local t = use_actor:combatGetTraining(combat)
		if t and t.name then desc:add( mod_align_stat( "Mastery" ), {"color","GOLD"}, t.name, {"color","LAST"}, true) end
	end

	self:descAccuracyBonus(desc, combat, use_actor)

	if combat.wil_attack then
		desc:add( mod_align_stat( "Accuracy Stat" ), "Wil", true)
	end

	compare_fields(combat, compare_with, field, "atk", "%+d",                   mod_align_stat( "Accuracy" ), 1, false, false, add_table)
	compare_fields(combat, compare_with, field, "apr", "%+d",                   mod_align_stat( "Ignore Armor" ), 1, false, false, add_table)
	compare_fields(combat, compare_with, field, "physcrit", "%+.1f%%",          mod_align_stat( "Critical Rate" ), 1, false, false, add_table)
	compare_fields(combat, compare_with, field, "crit_power", "%+.1f%%",        mod_align_stat( "Critical Power" ), 1, false, false, add_table)
	local physspeed_compare = function(orig, compare_with)
		orig = 100 / orig
		if compare_with then return ("%+.0f%%"):format(orig - 100 / compare_with)
		else return ("%2.0f%%"):format(orig) end
	end
	compare_fields(combat, compare_with, field, "physspeed", physspeed_compare, mod_align_stat( "Attack Speed" ), 1, false, true, add_table)
	compare_fields(combat, compare_with, field, "block", "%+d",                 mod_align_stat( "Block" ), 1, false, false, add_table)
	compare_fields(combat, compare_with, field, "dam_mult", "%d%%",             mod_align_stat( "Damage Multiplier" ), 100, false, false, add_table)
	compare_fields(combat, compare_with, field, "range", "%+d",                 mod_align_stat( "Range" ), 1, false, false, add_table)
	compare_fields(combat, compare_with, field, "capacity", "%d",               mod_align_stat( "Capacity" ), 1, false, false, add_table)
	compare_fields(combat, compare_with, field, "shots_reloaded_per_turn","%+d",mod_align_stat( "Reload" ), 1, false, false, add_table)
	compare_fields(combat, compare_with, field, "ammo_every", "%d",             mod_align_stat( "Auto Reload" ), 1, false, false, add_table)
	compare_fields(combat, compare_with, field, "travel_speed", "%+d%%",        mod_align_stat( "Projectile Speed" ), 100, false, false, add_table)
	compare_fields(combat, compare_with, field, "phasing", "%+d%%",             mod_align_stat( "Ignore Shields" ), 1, false, false, add_table)
	compare_fields(combat, compare_with, field, "lifesteal", "%+d%%",           mod_align_stat( "Lifesteal" ), 1, false, false, add_table)
	
	compare_table_fields(
		combat, compare_with, field, "melee_project", "%+d",                      mod_align_stat( "On-hit" ),
		function(item)
			local col = (DamageType.dam_def[item] and 
									 DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
			return col[2], mod_eff_name( (" %s"):format(DamageType.dam_def[item].name) ),{"color","LAST"}
		end,
		nil, nil,
		function(k, v) return not DamageType.dam_def[k].tdesc end)

	compare_table_fields(
		combat, compare_with, field, "ranged_project", "%+d",                     mod_align_stat( "On-ranged-hit" ),
		function(item)
			local col = (DamageType.dam_def[item] and 
									 DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
			return col[2], mod_eff_name( (" %s"):format(DamageType.dam_def[item].name) ),{"color","LAST"}
		end,
		nil, nil,
		function(k, v) return not DamageType.dam_def[k].tdesc end)
	
	compare_table_fields(combat, compare_with, field, "convert_damage", "%d%%", mod_align_stat( "Damage Conversion" ), function(item)
												 local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
												 return col[2], (" %s"):format(DamageType.dam_def[item].name),{"color","LAST"}
	end)
	
	compare_table_fields(combat, compare_with, field, "inc_damage_type", "%+d%% ", mod_align_stat( "Damage Against" ), function(item)
												 local _, _, t, st = item:find("^([^/]+)/?(.*)$")
												 if st and st ~= "" then
													 return st:capitalize()
												 else
													 return t:capitalize()
												 end
	end)
	
	compare_table_fields(combat, compare_with, field, "burst_on_hit", "%+d", mod_align_stat( "On-Hit, radius 1" ), function(item)
												 local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
												 return col[2], (" %s"):format(DamageType.dam_def[item].name),{"color","LAST"}
	end)
	
	compare_table_fields(combat, compare_with, field, "burst_on_crit", "%+d", mod_align_stat( "On-crit, radius 2" ), function(item)
												 local col = (DamageType.dam_def[item] and DamageType.dam_def[item].text_color or "#WHITE#"):toTString()
												 return col[2], (" %s"):format(DamageType.dam_def[item].name),{"color","LAST"}
	end)
	
	desc:merge( talent_on_hit_desc( "talent_on_hit", "Hit:" ) )
	desc:merge( talent_on_hit_desc( "talent_on_crit", "Crit:" ) )

	-- get_items takes the combat table and returns a table of items to print.
	-- Each of these items one of the following:
	-- id -> {priority, string}
	-- id -> {priority, message_function(this, compared), value}
	-- header is the section header.
	local compare_list = function(header, get_items)
		local priority_ordering = function(left, right)
			return left[2][1] < right[2][1]
		end

		if next(compare_with) then
			-- Grab the left and right items.
			local left = get_items(combat)
			local right = {}
			for i, v in ipairs(compare_with) do
				for k, item in pairs(get_items(v[field])) do
					if not right[k] then
						right[k] = item
					elseif type(right[k]) == 'number' then
						right[k] = right[k] + item
					else
						right[k] = item
					end
				end
			end

			-- Exit early if no items.
			if not next(left) and not next(right) then return end

			desc:add({'color','GREEN'},header,{'color','LAST'},true)

			local combined = table.clone(left)
			table.merge(combined, right)

			for k, _ in table.orderedPairs2(combined, priority_ordering) do
				l = left[k]
				r = right[k]
				message = (l and l[2]) or (r and r[2])
				if type(message) == 'function' then
					desc:add("#GREEN#",message(l and l[3], r and r[3] or 0):gsub("#LAST#","#GREEN#"), "#WHITE#", true)
				elseif type(message) == 'string' then
					local prefix = '* '
					local color = 'GREEN'
					if l and not r then
						color = 'GREEN'
						prefix = '+ '
					end
					if not l and r then
						color = 'RED'
						prefix = '- '
					end
					desc:add({'color',color}, prefix, mod_hl_values(message), {'color','WHITE'}, true)
				end
			end
		else
			local items = get_items(combat)
			if next(items) then
				desc:add({'color','GREEN'},header,{'color','LAST'},true)
				for k, v in table.orderedPairs2(items, priority_ordering) do
					message = v[2]
					if type(message) == 'function' then
						desc:add("#GREEN#",message(v[3]):gsub("#LAST#","#GREEN#"), "#WHITE#", true)
					elseif type(message) == 'string' then
						desc:add({'color','GREEN'}, '* ', mod_hl_values(message), {'color','WHITE'}, true)
					end
				end
			end
		end
	end

	local get_special_list = function(combat, key)
		local special = combat[key]

		-- No special
		if not special then return {} end
		-- Single special
		if special.desc then
			return {[special.desc] = {10, util.getval(special.desc, self, use_actor, special)}}
		end

		-- Multiple specials
		local list = {}
		for _, special in pairs(special) do
			list[special.desc] = {10, util.getval(special.desc, self, use_actor, special)}
		end
		return list
	end

	compare_list(
		"On Hit:",
		function(combat)
			if not combat then return {} end
			local list = {}
			-- Get complex damage types
			for dt, amount in pairs(combat.melee_project or combat.ranged_project or {}) do
				local dt_def = DamageType:get(dt)
				if dt_def and dt_def.tdesc then
					local desc = function(dam)
						return dt_def.tdesc(dam, nil, use_actor)
					end
					list[dt] = {0, desc, amount}
				end
			end
			-- Get specials
			table.merge(list, get_special_list(combat, 'special_on_hit'))
			return list
		end
	)

	compare_list(
		"On Crit:",
		function(combat)
			if not combat then return {} end
			return get_special_list(combat, 'special_on_crit')
		end
	)

	compare_list(
		"On Kill:",
		function(combat)
			if not combat then return {} end
			return get_special_list(combat, 'special_on_kill')
		end
	)

	local found = false
	for i, v in ipairs(compare_with or {}) do
		if v[field] and v[field].no_stealth_break then
			found = true
		end
	end

	if combat.no_stealth_break then
		desc:add(found and {"color","WHITE"} or {"color",mod_PASS_PWR_COLOR},"When used from stealth a simple attack with it will not break stealth.", {"color","LAST"}, true)
	elseif found then
		desc:add({"color","RED"}, "When used from stealth a simple attack with it will not break stealth.", {"color","LAST"}, true)
	end

	if combat.crushing_blow then
		desc:add({"color", mod_PASS_PWR_COLOR}, "Crushing Blows: Damage dealt by this weapon is increased by half your critical multiplier, if doing so would kill the target.", {"color", "LAST"}, true)
	end
	
	local attack_recurse_procs_reduce_compare = function(orig, compare_with)
		orig = 100 - 100 / orig
		if compare_with then return ("%+d%%"):format(-(orig - (100 - 100 / compare_with)))
		else return ("%d%%"):format(-orig) end
	end
	compare_fields(combat, compare_with, field, "attack_recurse", "%+d", mod_align_stat( "Recursive" ), 1, false, false, add_table)
	compare_fields(combat, compare_with, field, "attack_recurse_procs_reduce", attack_recurse_procs_reduce_compare, mod_align_stat( "Recursion Amount" ), 1, true, false, add_table)

	if combat.tg_type and combat.tg_type == "beam" then
		desc:add({"color",mod_PASS_PWR_COLOR}, "Shoots beams through all targets.", {"color","LAST"}, true)
	end

	-- resources used to attack
	compare_table_fields(
		combat, compare_with, field, "use_resources", "%0.1f", "#ORANGE#" .. mod_align_stat( "Uses" ) .. "#LAST#",
		function(item)
			local res_def = ActorResource.resources_def[item]
			local col = (res_def and res_def.color or "#SALMON#"):toTString()
			return col[2], (" %s"):format(res_def and res_def.name or item:capitalize()),{"color","LAST"}
		end,
		nil,
		true)

	self:triggerHook{"Object:descCombat", compare_with=compare_with, compare_fields=compare_fields, compare_scaled=compare_scaled, compare_scaled=compare_scaled, compare_table_fields=compare_table_fields, desc=desc, combat=combat}
	return desc
end

local base_descAccuracyBonus = _M.descAccuracyBonus
function _M:descAccuracyBonus(desc, weapon, use_actor)
	if core.key.modState("alt") then
		return base_descAccuracyBonus(self, desc, weapon, use_actor)
	end
	use_actor = use_actor or game.player
	local _, kind = use_actor:isAccuracyEffect(weapon)
	if not kind then return end

	local showpct = function(v, mult)
		return ("+%0.1f%%"):format(v * mult)
	end

	local m = weapon.accuracy_effect_scale or 1
	if kind == "sword" then
		desc:add( mod_align_stat( "Accuracy Bonus" ), {"color","LIGHT_GREEN"}, showpct(0.4, m), {"color","LAST"}, " critical power (max 40%)", true)
	elseif kind == "axe" then
		desc:add( mod_align_stat( "Accuracy Bonus" ), {"color","LIGHT_GREEN"}, showpct(0.25, m), {"color","LAST"}, " critical chance (max 25%)", true)
	elseif kind == "mace" then
		desc:add( mod_align_stat( "Accuracy Bonus" ), {"color","LIGHT_GREEN"}, showpct(0.2, m), {"color","LAST"}, " base damage (max 20%)", true)
	elseif kind == "staff" then
		desc:add( mod_align_stat( "Accuracy Bonus" ), {"color","LIGHT_GREEN"}, showpct(2.5, m), {"color","LAST"}, " proc damage (max 250%)", true)
	elseif kind == "knife" then
		desc:add( mod_align_stat( "Accuracy Bonus" ), {"color","LIGHT_GREEN"}, showpct(0.5, m), {"color","LAST"}, " Ignore Armor (max 50%)", true)
	end
end

function _M:compareTableFields(item1, items, infield, field, outformat, text, kfunct, mod, isinversed, filter)
	mod = mod or 1
	isinversed = isinversed or false
	local ret = tstring{}
	local added = 0
	local add = false
	ret:add(text)
	local tab = {}
	if item1[field] then
		for k, v in pairs(item1[field]) do
			tab[k] = {}
			tab[k][1] = v
		end
	end
	for i=1, #items do
		if items[i][infield] and items[i][infield][field] then
			for k, v in pairs(items[i][infield][field]) do
				tab[k] = tab[k] or {}
				tab[k][i + 1] = v
			end
		end
	end
	local count1 = 0
	local mod_sep = nil
	local testStr = tstring{}
	for k, v in pairs(tab) do
		if not filter or filter(k, v) then
			testStr:add((count1==0 and text or " "), outformat:format((v[1] or 0)), kfunct(k))
			if mod_is_exceed_tlp( testStr ) then
				mod_sep = mod_align_stat( "\n", 1 )
				testStr = tstring{mod_sep,outformat:format((v[1] or 0)), kfunct(k)}
			else
				mod_sep = " "
			end
			local count = 0
			if isinversed then
				ret:add(("%s"):format((count1 > 0) and mod_sep or ""), (v[1] or 0) > 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((v[1] or 0)), {"color","LAST"})
			else
				ret:add(("%s"):format((count1 > 0) and mod_sep or ""), (v[1] or 0) < 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((v[1] or 0)), {"color","LAST"})
			end
			count1 = count1 + 1
			if v[1] then
				add = true
			end
			for kk, vv in pairs(v) do
				if kk > 1 then
					if count == 0 then
						ret:add("(")
					elseif count > 0 then
						ret:add(mod_sep)
					end
					if vv ~= (v[1] or 0) then
						if isinversed then
							ret:add((v[1] or 0) > vv and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((v[1] or 0) - vv), {"color","LAST"})
						else
							ret:add((v[1] or 0) < vv and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((v[1] or 0) - vv), {"color","LAST"})
						end
					else
						ret:add("-")
					end
					add = true
					count = count + 1
				end
			end
			if count > 0 then
				ret:add(")")
			end
			ret:add(kfunct(k))
		end
	end

	if add then
		ret:add(true)
		return ret
	end
end

-- get the textual description of the object's usable power
local base_getUseDesc = _M.getUseDesc
function _M:getUseDesc(use_actor)
	if core.key.modState("alt") then
		return base_getUseDesc(self, use_actor)
	end
	use_actor = use_actor or game.player
	local ret = nil
	local reduce = 100 - util.bound(use_actor:attr("use_object_cooldown_reduce") or 0, 0, 100)
	local usepower = function(power) return math.ceil(power * reduce / 100) end
	local s_activ_pow = ""
	local s_activ_tal = ""
	if self.use_no_energy and self.use_no_energy ~= "fake" then
		s_activ_pow = "\nActivation is instant."
	elseif self.use_talent then
		local t = use_actor:getTalentFromId(self.use_talent.id)
		if util.getval(t.no_energy, use_actor, t) == true then
			s_activ_tal = " (Instant)"
		end
	end
	if self.use_power and not self.use_power.hidden then
		local desc = util.getval(self.use_power.name, self, use_actor)
		if self.show_charges then
			ret = tstring{{"color",mod_USABLE_COLOR}, ("%s."):format(mod_hl_values(desc:capitalize())),{"color","LAST"},true,
				{"color",mod_USABLE_COLOR2}, ("Uses %d charges out of %d"):format(math.floor(self.power / usepower(self.use_power.power)), math.floor(self.max_power / usepower(self.use_power.power))), 
				s_activ_pow, {"color","LAST"}}
		elseif self.talent_cooldown then
			local t_name = self.talent_cooldown == "T_GLOBAL_CD" and "all charms" or "Talent "..use_actor:getTalentDisplayName(use_actor:getTalentFromId(self.talent_cooldown))
			ret = tstring{{"color",mod_USABLE_COLOR}, ("%s"):format(mod_hl_values(desc:format(self:getCharmPower(use_actor)):capitalize())),{"color","LAST"},true,
				{"color",mod_USABLE_COLOR2}, ("Puts %s on %d turn cooldown"):format(t_name, usepower(self.use_power.power)), 
				s_activ_pow, {"color","LAST"}}
		else
			ret = tstring{{"color",mod_USABLE_COLOR}, ("%s."):format(mod_hl_values(desc:capitalize())),{"color","LAST"},true,
				{"color",mod_USABLE_COLOR2}, ("Uses %d power out of %d/%d"):format(usepower(self.use_power.power), self.power, self.max_power), 
				s_activ_pow, {"color","LAST"}}
		end
	elseif self.use_simple then
		ret = tstring{{"color",mod_USABLE_COLOR}, ("%s."):format(util.getval(self.use_simple.name, self, use_actor)):capitalize(), {"color","LAST"}}
	elseif self.use_talent then
		local t = use_actor:getTalentFromId(self.use_talent.id)
		if t then
			local desc = use_actor:getTalentFullDescription(t, nil, {force_level=self.use_talent.level, ignore_cd=true, ignore_ressources=true, ignore_use_time=true, ignore_mode=true, tooltip_mode=true,
																															 custom=self.use_talent.power and tstring{{"color",0x6f,0xff,0x83}, mod_align_stat( "Power cost" ), {"color",0x7f,0xff,0xd4},
																																 ("%d out of %d/%d."):format(usepower(self.use_talent.power), self.power, self.max_power)}})
			if self.talent_cooldown then
				ret = tstring{{"color",mod_USABLE_COLOR}, t.name, ":", s_activ_tal, {"color","LAST"}, true, 
					{"color",mod_USABLE_COLOR2}, ("Puts all charms on %d turn cooldown"):format( tostring(math.floor(usepower(self.use_talent.power))) ), {"color","LAST"}, true}
			else
				ret = tstring{{"color",mod_USABLE_COLOR}, t.name, ":", s_activ_tal, {"color","LAST"}, true}
				-- {"color",mod_USABLE_COLOR2}, ("Uses %d power out of %d/%d"):format(tostring(math.floor(usepower(self.use_talent.power))), tostring(math.floor(self.power)), tostring(math.floor(self.max_power)) ), {"color","LAST"}, true}
			end
			ret:merge(desc)
		end
	end

	if self.charm_on_use then
		ret = ret or tstring{}
		ret:add(true, {"color",mod_USABLE_COLOR2})
		for i, d in ipairs(self.charm_on_use) do
			ret:add(tostring(d[1]), "% to ", d[2](self, use_actor), "." )
			if i ~= #self.charm_on_use then
				ret:add( true )
			end
		end
		ret:add( {"color","LAST"} )
	end

	return ret
end

return _M
