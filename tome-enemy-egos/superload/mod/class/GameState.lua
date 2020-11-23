require "engine.class"
require "engine.Entity"
local Map = require "engine.Map"
local NameGenerator = require "engine.NameGenerator"
local NameGenerator2 = require "engine.NameGenerator2"

local _M = loadPrevious(...)


function _M:createRandomName(name_def, name_scheme, base_name)
	local ngd, name
	if not name_def and self.birth.world_base_random_name_def then name_def = self.birth.world_base_random_name_def end
	if name_def then
		ngd = NameGenerator2.new("/data/languages/names/"..name_def:gsub("#sex#", base.female and "female" or "male")..".txt")
		name = ngd:generate(nil, base.random_name_min_syllables, base.random_name_max_syllables)
	else
		ngd = NameGenerator.new(self:getRandartNameRule().default)
		name = ngd:generate()
	end
	-- TODO add _t in 1.7
	if name_scheme then

		name = name_scheme:gsub("#rng#", name):gsub("#base#", (base_name))
	else
		name = ("%s the %s"):format(name, (base_name))
	end
	return name
end

function _M:bossApplyBasicPowers(b, forbid_equip)
	b.max_life = b.max_life or 150
	b.max_inscriptions = 5 -- Note:  This usually won't add inscriptions to NPC bases without them
	
	-- Avoid cloning randbosses
	if b.can_multiply or b.clone_on_hit then
		b.can_multiply = nil
		b.clone_on_hit = nil
	end
	
	-- Force resolving some stuff
	if type(b.max_life) == "table" and b.max_life.__resolver then b.max_life = resolvers.calc[b.max_life.__resolver](b.max_life, b, b, b, "max_life", {}) end
	
	-- All bosses have all body parts .. yes snake bosses can use archery and so on ..
	-- This is to prevent them from having unusable talents
	b.inven = {}
	b.body = { INVEN = 1000, QS_MAINHAND = 1, QS_OFFHAND = 1, MAINHAND = 1, OFFHAND = 1, FINGER = 2, NECK = 1, LITE = 1, BODY = 1, HEAD = 1, CLOAK = 1, HANDS = 1, BELT = 1, FEET = 1, TOOL = 1, QUIVER = 1, QS_QUIVER = 1 }
	b:initBody()

	-- don't auto equip inventory if forbidden
	if forbid_equip then b.inven[b.INVEN_INVEN]._no_equip_objects = true end
	
	b:resolve()
	-- Start with sustains sustained
	b[#b+1] = resolvers.sustains_at_birth()

	-- Leveling stats
	b.autolevel = "random_boss"
	b.auto_stats = {}

	-- Randbosses resemble players so they should use the same resist cap rules
	-- This is particularly important because at high levels boss ranks get a lot of free resist all
	b.resists_cap = { all = 70 }

	b.move_others = true
	b.open_door = true
end

function _M:bossResolveLife(b, level, life_function)
	b.level_range[1] = level
	b.fixed_rating = true
	b.life_rating = life_function and life_function(b.life_rating) or b.life_rating * 1.7 + rng.range(4, 9)
end

function _M:bossBoostEquipment(b, data)
	-- Update default equipment, if any, to "boss" levels
	for k, resolver in ipairs(b) do
		if type(resolver) == "table" and resolver.__resolver == "equip" then
			resolver[1].id = nil
			for i, d in ipairs(resolver[1]) do
				d.name, d.id = nil, nil
				d.ego_chance = nil
				d.ignore_material_restriction = true
				d.forbid_power_source = b.not_power_source
				d.tome_drops = data.loot_quality or "boss"
				d.force_drop = (data.drop_equipment == nil) and true or data.drop_equipment
			end
		end
	end
	
	-- Boss worthy drops
	b[#b+1] = resolvers.drops{chance=100, nb=data.loot_quantity or 3, {tome_drops=data.loot_quality or "boss"} }
	if not data.no_loot_randart then b[#b+1] = resolvers.drop_randart{} end
	if data.loot_unique then b[#b+1] = resolvers.drops{chance=100, nb=1, {unique=true, not_properties={"lore"}} } end
end

function _M:bossAIUpgrade(b, ai, tactic)
	if ai then b.ai = ai
	else b.ai = (b.rank > 3) and "tactical" or b.ai
	end
	b.ai_state = { talent_in=1 }
	if not b.no_overwrite_ai_move then 
		b.ai_state.ai_move = "move_astar_advanced" 
	end

	if tactic then
		b.ai_tactic = tactic
	else
		b[#b+1] = resolvers.talented_ai_tactic() --calculate ai_tactic table based on talents
	end
end


local function on_added_to_level(self, ...)
	self:check("birth_create_alchemist_golem")
	self:check("rnd_boss_on_added_to_level", ...)
	self.rnd_boss_on_added_to_level = nil
	self.on_added_to_level = nil
	
	-- Increase talent cds
	if self._rndboss_talent_cds then
		local fact = self._rndboss_talent_cds
		for tid, _ in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t.mode ~= "passive" then
				local bcd = self:getTalentCooldown(t) or 0
				self.talent_cd_reduction[tid] = (self.talent_cd_reduction[tid] or 0) - math.ceil(bcd * (fact - 1))
			end
		end
	end
	
	-- Enhance resource pools (cheat a bit with recovery)
	for res, res_def in ipairs(self.resources_def) do
		if res_def.randomboss_enhanced then
			local capacity
			if self[res_def.minname] and self[res_def.maxname] then -- expand capacity
				capacity = (self[res_def.maxname] - self[res_def.minname]) * self._rndboss_resources_boost
			end
			if res_def.invert_values then
				if capacity then self[res_def.minname] = self[res_def.maxname] - capacity end
				self[res_def.regen_prop] = self[res_def.regen_prop] - (res_def.min and res_def.max and (res_def.max-res_def.min)*.01 or 1) * self._rndboss_resources_boost
			else
				if capacity then self[res_def.maxname] = self[res_def.minname] + capacity end
				self[res_def.regen_prop] = self[res_def.regen_prop] + (res_def.min and res_def.max and (res_def.max-res_def.min)*.01 or 1) * self._rndboss_resources_boost
			end
		end
	end
	self:resetToFull()
end
_M.on_added_to_level = on_added_to_level

-- default 2 classes
-- check actor-specific rand boss data
-- get name
-- determine boss or unique
-- life
-- basic qualities
-- equipment
-- classes
-- boost resources
-- upgrade AI
-- cleanup

--- Creates a random Boss (or elite) actor (pre-NPC autolevel method)
--	@param base = base actor to add classes/talents to
--		handles data.nb_classes, data.force_classes, data.class_filter, ...
--	optional parameters:
--	@param data.init = function(data, b) to run before generation
--	@param data.level = minimum level range for actor generation <1>
--	@param data.rank = rank <3.5-4>
--	@param data.life_rating = function(b.life_rating) <1.7 * base.life_rating + 4-9>
--	@param data.resources_boost = multiplier for maximum resource pool sizes <3>
--	@param data.talent_cds_factor = multiplier for all talent cooldowns <1>
--	@param data.ai = ai_type <"tactical" if rank>3 or base.ai>
--	@param data.ai_tactic = tactical weights table for the tactical ai <nil - generated based on talents>
--	@param data.no_loot_randart set true to not drop a randart <nil>
--  @param data.loot_fixedart set true to drop a fixedart <nil>
--	@param data.on_die set true to run base.rng_boss_on_die and base.rng_boss_on_die_custom on death <nil>
--	@param data.name_scheme <randart_name_rules.default>
--	@param data.post = function(b, data) to run last to finish generation
function _M:createRandomBoss(base, data)
	local b = base:clone()
	data = data or {level=1}
	if data.init then data.init(data, b) end
	data.nb_classes = data.nb_classes or 2

	if b.rnd_boss_init then b.rnd_boss_init(b, data) end -- Used for problematic randboss bases, banning classes/talents,  ...
	
	------------------------------------------------------------
	-- Basic stuff, name, rank, ...
	------------------------------------------------------------
	b.name = self:createRandomName(base.random_name_def, data.name_scheme, b.name)
	
	print("[createRandomBoss] Creating random boss ", b.name, data.level, "level", data.nb_classes, "classes")
	if data.force_classes then print("  * force_classes:", (string.fromTable(data.force_classes))) end
	b.unique = b.name
	b.randboss = true
	local boss_id = "RND_BOSS_"..b.name:upper():gsub("[^A-Z]", "_")
	b.define_as = boss_id
	b.color = colors.VIOLET
	
	-- 30% chance of boss rank
	b.rank = data.rank or (rng.percent(self.default_randboss_promotion_chance or 30) and 4 or 3.5)

	print("DEBUG [createRandomBoss] set rank to ", b.rank)

	self:bossResolveLife(b, data.level, data.life_rating)
	print("DEBUG [createRandomBoss] resolved life")
	self:bossApplyBasicPowers(b, data.forbid_equip)
	print("DEBUG [createRandomBoss] set basic powers")
	self:bossBoostEquipment(b, data)
	print("DEBUG [createRandomBoss] set equipment")

	-- On die
	if data.on_die then
		b.rng_boss_on_die = b.on_die
		b.rng_boss_on_die_custom = data.on_die
		b.on_die = function(self, src)
			self:check("rng_boss_on_die_custom", src)
			self:check("rng_boss_on_die", src)
		end
	end

	------------------------------------------------------------
	-- Apply 'classes'
	------------------------------------------------------------
	self:applyRandomEnemyEgo(b, data)
	print("DEBUG [createRandomBoss] classApplied")

	b.rnd_boss_on_added_to_level = b.on_added_to_level
	b.on_added_final = data.rnd_boss_final_adjust
	b._rndboss_resources_boost = data.resources_boost or 3
	b._rndboss_talent_cds = data.talent_cds_factor
	
	b.on_added_to_level = self.on_added_to_level

	self:bossAIUpgrade(b, data.ai, data.ai_tactic)
	
	-- Anything else
	if data.post then data.post(b, data) end

	return b, boss_id
end


function _M:apply_enemy_ego(b, class, data)
	local Birther = require "engine.Birther"
	local mclasses = Birther.birth_descriptor_def.class
		local mclass = nil
		for name, data in pairs(mclasses) do
			if data.descriptor_choices and data.descriptor_choices.subclass and data.descriptor_choices.subclass[class.name] then mclass = data break end
		end
		if not mclass then return end

		-- THE MOTHER OF ALL HACKS!
		-- Make sure brawlers rares dont get absurdly powerful
		if class.npc_class_use_default_combat_table then
			b.combat_old = table.clone(b.combat or {}, true)
			b.combat = {
				dam=1,
				atk=1, apr=0,
				physcrit=0,
				physspeed =1,
				dammod = { str=1 },
				damrange=1.1,
				talented = "unarmed",
				npc_brawler_combat_hack_enabled = true,
			}
			if b.combat_old.sound then b.combat.sound = b.combat_old.sound end
			if b.combat_old.sound_miss then b.combat.sound_miss = b.combat_old.sound_miss end
		end

		print("[applyRandomClass]", b.uid, b.name, "Adding class", class.name, mclass.name)
		-- add class to list and build inherent power sources
		b.descriptor = b.descriptor or {}
		b.descriptor.classes = b.descriptor.classes or {}
		table.append(b.descriptor.classes, {class.name})
		
		-- build inherent power sources and forbidden power sources
		-- b.forbid_power_source --> b.not_power_source used for classes
		b.power_source = table.merge(b.power_source or {}, class.power_source or {})
		b.not_power_source = table.merge(b.not_power_source or {}, class.not_power_source or {})
		-- update power source parameters with the new class
		b.not_power_source, b.power_source = self:updatePowers(self:attrPowers(b, b.not_power_source), b.power_source)
		print("   power types: not_power_source =", table.concat(table.keys(b.not_power_source),","), "power_source =", table.concat(table.keys(b.power_source),","))

		-- Update/initialize base stats, set stats auto_leveling
		if class.stats or b.auto_stats then
			b.stats, b.auto_stats = b.stats or {}, b.auto_stats or {}
			for stat, v in pairs(class.stats or {}) do
				local stat_id = b.stats_def[stat].id
				b.stats[stat_id] = (b.stats[stat_id] or 10) + v
				for i = 1, v do b.auto_stats[#b.auto_stats+1] = stat_id end
			end
		end
		if data.autolevel ~= false then b.autolevel = data.autolevel or "random_boss" end
		
		-- Class talent categories
		local ttypes = {}
		for tt, d in pairs(mclass.talents_types or {}) do b:learnTalentType(tt, true) b:setTalentTypeMastery(tt, (b:getTalentTypeMastery(tt, true) or 1) + d[2]) ttypes[tt] = table.clone(d) end
		for tt, d in pairs(mclass.unlockable_talents_types or {}) do b:learnTalentType(tt, true) b:setTalentTypeMastery(tt, (b:getTalentTypeMastery(tt, true) or 1) + d[2]) ttypes[tt] = table.clone(d) end
		for tt, d in pairs(class.talents_types or {}) do b:learnTalentType(tt, true) b:setTalentTypeMastery(tt, (b:getTalentTypeMastery(tt, true) or 1) + d[2]) ttypes[tt] = table.clone(d) end
		for tt, d in pairs(class.unlockable_talents_types or {}) do b:learnTalentType(tt, true) b:setTalentTypeMastery(tt, (b:getTalentTypeMastery(tt, true) or 1) + d[2]) ttypes[tt] = table.clone(d) end

		-- Non-class talent categories
		if data.add_trees then
			for tt, d in pairs(data.add_trees) do
				if not b:knowTalentType(tt) then
					if type(d) ~= "number" then d = rng.range(1, 3)*0.1 end
					b:learnTalentType(tt, true)
					b:setTalentTypeMastery(tt, (b:getTalentTypeMastery(tt, true) or 1) + d)
					ttypes[tt] = {true, d}
				end
			end
		end

		-- Add starting equipment
		local apply_resolvers = function(k, resolver)
			if type(resolver) == "table" and resolver.__resolver then
				if resolver.__resolver == "equip" then
					if not data.forbid_equip then
						resolver[1].id = nil
						-- Make sure we equip some nifty stuff instead of player's starting iron stuff
						for i, d in ipairs(resolver[1]) do
							d.name, d.id = nil, nil
							d.ego_chance = nil
							d.ignore_material_restriction = true
							d.forbid_power_source = table.clone(b.not_power_source, nil, {nature=true})
							d.tome_drops = data.loot_quality or "boss"
							d.force_drop = (data.drop_equipment == nil) and true or data.drop_equipment
						end
						b[#b+1] = resolver
					end
				elseif resolver.__resolver == "auto_equip_filters" then
					if not data.forbid_equip then
						b[#b+1] = resolver
					end
				elseif resolver._allow_random_boss then -- explicitly allowed resolver
					b[#b+1] = resolver
				end
			elseif k == "innate_alchemy_golem" then 
				b.innate_alchemy_golem = true
			elseif k == "birth_create_alchemist_golem" then
				b.birth_create_alchemist_golem = resolver
			elseif k == "soul" then
				b.soul = util.bound(1 + math.ceil(data.level / 10), 1, 10) -- Does this need to scale?
			elseif k == "can_tinker" then
				b[k] = table.clone(resolver)
			end
		end
		for k, resolver in pairs(mclass.copy or {}) do apply_resolvers(k, resolver) end
		for k, resolver in pairs(class.copy or {}) do apply_resolvers(k, resolver) end

		-- Assign a talent resolver for class starting talents (this makes them autoleveling)
		local tres = nil
		for k, resolver in pairs(b) do if type(resolver) == "table" and resolver.__resolver and resolver.__resolver == "talents" then tres = resolver break end end
		if not tres then tres = resolvers.talents{} b[#b+1] = tres end
		for tid, v in pairs(class.talents or {}) do
			local t = b:getTalentFromId(tid)
			if not t.no_npc_use and not t.no_npc_autolevel and (not t.random_boss_rarity or rng.chance(t.random_boss_rarity)) and not (t.rnd_boss_restrict and util.getval(t.rnd_boss_restrict, b, t, data) ) then
				local max = (t.points == 1) and 1 or math.ceil(t.points * 1.2)
				local step = max / 70
				tres[1][tid] = v + math.ceil(step * data.level)
			end
		end

		-- learn talents based on trees: focus trees we take 3-4 talents from with a decent amount of point investment, shallow trees we only take 1 or 2 with not many points
		-- ideally rares should feel different even within the same class based on what focus trees they get
		local nb_focus, nb_shallow = 0, 0
		local rank = b.rank
		if rank <= 3.2 then 	--rare
			nb_focus = math.floor(0.2 + rng.float(0.22, 0.35)*(math.max(0,data.level-3))^0.5)
			nb_shallow = 2 + math.floor(0.25 + rng.float(0.08, 0.2)*(math.max(0,data.level-6))^0.5)
		elseif rank >= 4 then 	--boss/elite boss 
			nb_focus = 1 + math.floor(0.25 + rng.float(0.15, 0.35)*(math.max(0,data.level-6))^0.5)
			nb_shallow = 1 + math.floor(0.3 + rng.float(0.1, 0.2)*(math.max(0,data.level-4))^0.5)
		else 					--unique
			nb_focus = 1 + math.floor(0.2 + rng.float(0.15, 0.3)*(math.max(0,data.level-10))^0.5)
			nb_shallow = 1 + math.floor(0.55 + rng.float(0.1, 0.2)*(math.max(0,data.level-8))^0.5)
		end
		print("Adding "..nb_focus.." primary trees to boss")
		print("Adding "..nb_shallow.." secondary trees to boss")

 		local tt_choices = {}
		for tt, d in pairs(ttypes) do
			d.tt = tt
			table.insert(tt_choices, d)
		end
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		table.print(tt_choices)
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		
		local fails = 0
		local focus_trees = {}
		local shallow_trees = {}
		local tt, tt_idx, tt_def
		local t, t_idx
		while #focus_trees < nb_focus or #shallow_trees < nb_shallow do
			local ok = false
			while not ok do
				tt = rng.tableRemove(tt_choices)
				if not tt or not tt.tt then break end
				if not (tt.tt=="technique/combat-training" or tt.tt=="cunning/survival") then ok=true end
			end
			if not ok then break end
			tt = tt.tt
			tt_def = tt and b:knowTalentType(tt) and b.talents_types_def[tt]
			if not tt_def then break end
			print("[applyRandomClass] Attempting to add tree "..tt.." to boss")
			local t_choices = {}
			local nb_known = b:numberKnownTalent(tt)
			for i, t in ipairs(tt_def.talents) do
				local ok = true
				if t.no_npc_use or t.not_on_random_boss then
					nb_known = nb_known + 1 -- treat as known to allow later talents to be learned
					print(" * Random boss forbade talent because talent not allowed on random bosses", t.name, t.id, data.level)
					ok = false
				end
				if t.rnd_boss_restrict and util.getval(t.rnd_boss_restrict, b, t, data) and ok then
					print(" * Random boss forbade talent because of special talent restriction", t.name, t.id, data.level)
					nb_known = nb_known + 1 -- treat as known to allow later talents to be learned
					ok = false
				end
				if t.random_boss_rarity and rng.percent(t.random_boss_rarity) and ok then
					print(" * Random boss forbade talent because of random boss rarity random chance", t.name, t.id, data.level)
					nb_known = nb_known + 1 -- treat as known to allow later talents to be learned
					ok = false
				end
				if data.check_talents_level and rawget(t, 'require') and ok then
					local req = t.require
					if type(req) == "function" then req = req(b, t) end
					if req and req.level and util.getval(req.level, 1) > math.ceil(data.level) then
						print(" * Random boss forbade talent because of level", t.name, t.id, data.level)
						ok = false
					end
				end
				if ok then
					table.insert(t_choices, t)
				end
			end
			print(" Talent choices for "..tt..":")	for i, t in ipairs(t_choices) do print("\t", i, t.id, t.name) end
			if #t_choices <= 2 or #focus_trees >= nb_focus then 
				if #t_choices > 0 and #shallow_trees < nb_shallow then
					table.insert(shallow_trees, tt) -- record that we added the tree as a minor tree
					max_talents_from_tree = rng.percent(65) and 2 or 1
					print("Adding secondary tree "..tt.." to boss with "..max_talents_from_tree.." talents")
					for i = max_talents_from_tree,1,-1 do
						local t = table.remove(t_choices, 1)
						if not t then break end
						local max = (t.points == 1) and 1 or math.ceil(t.points * 1.2)
						local step = max / 60
						local lev = math.max(1, math.round(rng.float(0.75,1.15)*math.ceil(step * data.level)))
						print(#shallow_trees, " * talent:", t.id, lev)
						b.learn_tids[t.id] = lev
					end
				else 
					print("Tree "..tt.." rejected")
				end
			else
				table.insert(focus_trees, tt) --record that we added the tree as a major tree
				local max_talents_from_tree = rng.percent(75) and 4 or 3 
				print("Adding primary tree "..tt.." to boss with "..max_talents_from_tree.." talents")
				for i = max_talents_from_tree,1,-1 do
					local t = table.remove(t_choices, 1)
					if not t then break end
					local max = (t.points == 1) and 1 or math.ceil(t.points * 1.2)
					local step = max / 50
					local lev = math.max(1, math.round(rng.float(0.75,1.25)*math.ceil(step * data.level)))
					print(#focus_trees, " * talent:", t.id, lev)
					b.learn_tids[t.id] = lev
				end
			end
		end	
		print(" ** Finished adding", #focus_trees, "of", nb_focus, "primary class trees") for i, tt in ipairs(focus_trees) do print("\t * ", tt) end
		print(" ** Finished adding", #shallow_trees, "of", nb_shallow, "secondary class trees") for i, tt in ipairs(shallow_trees) do print("\t * ", tt) end

		return true
end

--- Add one or more character classes to an actor, updating stats, talents, and equipment
--	@param b = actor(boss) to update
--	@param data = optional parameters:
--	@param data.update_body a table of inventories to add, set true to add a full suite of inventories
--	@param data.force_classes = specific subclasses to apply first, ignoring restrictions
--		{"Rogue", "Necromancer", Corruptor = true, Bulwark = true, ...}
--		applied in order of numerical index, then randomly
--	@param data.nb_classes = random classes to add (in addition to any forced classes) <2>
-- 	@param data.class_filter = function(cdata, b) that must return true for any class picked.
--		(cdata, b = subclass definition in engine.Birther.birth_descriptor_def.subclass, boss (before classes are applied))
--	@param data.no_class_restrictions set true to skip class compatibility checks <nil>
--	@param data.autolevel = autolevel scheme to use for stats (set false to keep current) <"random_boss">
--	@param data.spend_points = spend any unspent stat points (after adding all classes)
--	@param data.add_trees = {["talent tree name 1"]=true/mastery bonus, ["talent tree name 2"]=true/mastery bonus, ..} additional talent trees to learn
--	@param data.check_talents_level set true to enforce talent level restrictions <nil>
--	@param data.auto_sustain set true to activate sustained talents at birth <nil>
--	@param data.forbid_equip set true to not apply class equipment resolvers or equip inventory <nil>
--	@param data.loot_quality = drop table to use for equipment <"boss">
--	@param data.drop_equipment set true to force dropping of equipment <nil>
function _M:applyRandomEnemyEgo(b, data)
	if not data.level then data.level = b.level end
	
	------------------------------------------------------------
	-- Apply talents from classes
	------------------------------------------------------------
	-- Apply a class
	local Birther = require "engine.Birther"
	b.learn_tids = {}
	
	-- add a full set of inventories if needed
	if data.update_body then
		b.body = type(data.update_body) == "table" and data.update_body or { INVEN = 1000, QS_MAINHAND = 1, QS_OFFHAND = 1, MAINHAND = 1, OFFHAND = 1, FINGER = 2, NECK = 1, LITE = 1, BODY = 1, HEAD = 1, CLOAK = 1, HANDS = 1, BELT = 1, FEET = 1, TOOL = 1, QUIVER = 1, QS_QUIVER = 1 }
		b:initBody()
	end
	
	local classes = Birther.birth_descriptor_def.subclass
	
	-- apply forced classes
	if data.force_classes then 
		local c_list = table.clone(data.force_classes)
		local force_classes = {}
		for i, c_name in ipairs(c_list) do
			force_classes[i] = c_list[i]
			c_list[i] = nil
		end
		table.append(force_classes, table.shuffle(table.keys(c_list)))
		for i, c_name in ipairs(force_classes) do
			if classes[c_name] then
				self:apply_enemy_ego(b, table.clone(classes[c_name], true), data)
			else
				print("  ###Forced class", c_name, "NOT DEFINED###")
			end
		end
	end

	
	local list = {}
	for name, cdata in ipairs(classes) do
		if (not cdata.not_on_random_boss
				and (not cdata.random_rarity or rng.chance(cdata.random_rarity))
				and (not data.class_filter or data.class_filter(cdata, b))) then
			list[#list+1] = cdata
		end
	end

	-- apply random classes
	local to_apply = (data.nb_classes or 2)*3
	while to_apply > 0 do
		local c = rng.tableRemove(list)
		if not c then break end --repeat attempts until list is exhausted
		if not c.enemy_ego_point_cost then c.enemy_ego_point_cost = 3 end
		if c.enemy_ego_point_cost <= to_apply then 
			if data.no_class_restrictions or self:checkPowers(b, c) then  -- recheck power restricts here to account for any previously picked classes
				print("DEBUG [createRandomBoss] applying class ", c.name)
				if self:apply_enemy_ego(b, table.clone(c, true), data) then
					to_apply = to_apply - (c.enemy_ego_point_cost or 1)
				end
			else
				print("  * class", c.name, " rejected due to power source")
			end
		end
	end
	if data.spend_points then -- spend any remaining unspent stat points
		repeat 
			local last_stats = b.unused_stats
			engine.Autolevel:autoLevel(b)
		until last_stats == b.unused_stats or b.unused_stats <= 0
	end
end

return _M
