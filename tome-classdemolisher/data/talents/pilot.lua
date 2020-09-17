newTalent{
	name = "Hull Pool",
	type = {"base/class", 1},
	info = "Allows you to have an Hull pool. Hull represent the structural integrity of your vehicle. Much like life, it is depleted by damage.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
	callbackOnStatChange = function(self, t, stat, v)	self:updateTalentPassives(t) end,
	passives = function(self, t, p)
		local max_hull = 0	
		self:talentTemporaryValue(p, "max_hull", max_hull)
		local hull_regen = 0 
		self:talentTemporaryValue(p, "hull_regen", hull_regen)
	end,
}

newTalent{
	name = "Steel Rider", short_name = "REK_DEML_PILOT_AUTOMOTOR",
	type = {"steamtech/pilot", 1},
	require = steam_req1,
	points = 5,
	steam = 35,
	cooldown = 25,
	no_npc_use = true,
	autolearn_talent = "T_HULL_POOL",
	getHull = function(self, t) return self.getMaxHull and self:getMaxHull() or 100 end,
	getPinImmune = function(self, t) return math.min(1, self:combatTalentScale(t, 0.1, 0.90, 0.5)) end,
	on_pre_use = function(self, t) return not self:hasEffect(self.EFF_REK_DEML_RIDE) end,
	on_learn = function(self, t)
		self.hull_rating = 5
	end,
	action = function(self, t)
		self:incHull(self:getMaxHull())
		local pin = t.getPinImmune(self,t)
		local armor = 0
		local speed = 0
		local def = 0
		if self:knowTalent(self.T_REK_DEML_PILOT_PATCH) then
			armor = self:callTalent(self.T_REK_DEML_PILOT_PATCH, "getArmor")
		end
		if self:knowTalent(self.T_REK_DEML_ENGINE_BLAZING_TRAIL) then
			speed = self:callTalent(self.T_REK_DEML_ENGINE_BLAZING_TRAIL, "getMovement")
		end
		if self:knowTalent(self.T_REK_DEML_ENGINE_DRIFT_NOZZLES) then
			def = self:callTalent(self.T_REK_DEML_ENGINE_DRIFT_NOZZLES, "getDefense")
		end
		self:setEffect(self.EFF_REK_DEML_RIDE, 10, {src=self, pin=pin, armor=armor, speed=speed, def=def})
		return true
	end,
	info = function(self, t)
		return ([[You travel in a peculiar contraption: a steam-powered, jet propelled, armored buggy.
Your ride has %d points of Hull, Healing and Damage are applied to Hull before they are applied to your life.  Hull increases with level, and you get 2 extra points per Constitution, and 4 extra points per Willpower.

Your ride is hard to stop.  While riding, you have %d%% resistance to pinning.]]):format(t.getHull(self, t), t.getPinImmune(self, t)*100)
	end,
}

newTalent{
	name = "Patch Job", short_name = "REK_DEML_PILOT_PATCH",
	type = {"steamtech/pilot", 2},
	require = steam_req2,
	points = 5,
	steam = 20,
	cooldown = 15,
	tactical = { HEAL = 2 },
	getHeal = function(self, t) return 40 + self:combatTalentSteamDamage(t, 20, 390) end,
	getArmor = function(self, t) return self:combatTalentScale(t, 1, 7, 0.75) end,
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_REK_DEML_RIDE) end,
	is_heal = true,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(self:steamCrit(t.getHeal(self, t)), self)
		self:attr("allow_on_heal", -1)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healarcane", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, beamColor1={0x8e/255, 0x2f/255, 0xbb/255, 1}, beamColor2={0xe7/255, 0x39/255, 0xde/255, 1}, circleDescendSpeed=4}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healarcane", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, beamColor1={0x8e/255, 0x2f/255, 0xbb/255, 1}, beamColor2={0xe7/255, 0x39/255, 0xde/255, 1}, circleDescendSpeed=4}))
		end
		
		game:playSoundNear(self, {"ambient/town/town_large2", vol=300}) -- Hammer clinking sound
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return ([[Make some battlefield repairs to your ride, healing it for %d hull.
The hull restored increases with Steampower and can be a critical hit.

Your familiarity with repairs lets you reinforce the vehicle's chassis.  While riding, you have %d extra armor.]]):format(t.getHeal(self, t), t.getArmor(self, t))
	end,
}

newTalent{
	name = "Choose Runeplate", short_name = "REK_DEML_CHOOSE_RUNE",
	type = {"steamtech/other", 1},
	points = 1,
	no_energy = true,
	cooldown = 0,
	no_npc_use = true,
	filterObject = function(self, t, o)
		if o.subtype == "rune" then return true end
		return false
	end,
	action = function(self, t)
		local inven = self:getInven("INVEN")
		local d = self:showInventory("Which rune do you wish to apply?", inven, function(o) return t.filterObject(self, ct, o) end, nil)
		d.action = function(o, item) self:talentDialogReturn(true, o, item) return false end
		local ret, o, item = self:talentDialog(d)
		if not ret then return nil end
		self.runeplate_inscription = o
		self.__inscription_data_fake = o.inscription_data
		local tal = self:getTalentFromId("T_"..o.inscription_talent.."_1")
		local tal_desc = tostring(self:getTalentFullDescription(tal, 1, nil, 1))
		local tal_name = tal.name
		game.logSeen(self, "#ORANGE#You apply %s to your ride's runeplate!#LAST#", tal_name)
		self.__inscription_data_fake = nil
		self:removeObject(inven, item)
		self:startTalentCooldown(self:getTalentFromId(self.T_REK_DEML_PILOT_RUNEPLATE))
		return true
	end,
	info = function(self, t)  
	return ([[Choose a rune to apply to your ride, removing the object from your inventory. Once choosen, you can activate the rune while riding.	The rune will retain the power and any stat scaling it may have had, but the cooldown is based solely on this talent.	A runeplate inscription does not count toward your limit for the type or total maximum numbers of inscriptions. The chosen inscription may be overwritten by using this talent again.]]) 
	end,
}

newTalent{
	name = "Activate Runeplate", short_name = "REK_DEML_PILOT_RUNEPLATE",
	type = {"steamtech/pilot", 3},
	require = steam_req3,
	points = 5,
	steam = 10,
	cooldown = function(self, t) return math.max(10, math.floor(self:combatTalentScale(t, 45, 25, 0.75))) end,
	innate = true,
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_REK_DEML_RIDE) end,
	on_learn = function(self, t)
		if not self:knowTalent(self:getTalentFromId(self.T_REK_DEML_CHOOSE_RUNE)) then
			self:learnTalent(self.T_REK_DEML_CHOOSE_RUNE, true, 1, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(self:getTalentFromId(self.T_REK_DEML_PILOT_RUNEPLATE)) and self:knowTalent(self:getTalentFromId(self.T_REK_DEML_CHOOSE_RUNE)) then
			self:unlearnTalent(self.T_REK_DEML_CHOOSE_RUNE)
		end
	end,
	action = function(self, t)
		if not self.runeplate_inscription then return false end
		local o = self.runeplate_inscription
		self.__inscription_data_fake = o.inscription_data
		local tal = self:getTalentFromId("T_"..o.inscription_talent.."_1")
		self:callTalent(tal.id, "action")
		self.__inscription_data_fake = nil
		self:startTalentCooldown(t)
	end,
	info = function(self, t) 
		local cd = t.cooldown(self, t)
		if not self.runeplate_inscription then 
			return ([[The chassis of your ride serves as a place to inscribe an additional inscription (though since it is not alive, it can only be a rune, not an infusion or injector).
			
			Use your 'Choose Runeplate' talent to choose a rune to apply. Once choosen, you can use the rune by activating this talent.	The inscription will inherit the power and any stat scaling the inscription may have had, but the cooldown is based solely on this talent and the inscription may not be activated in any other way.]]):format(cd) 
		else
			local o = self.runeplate_inscription
			self.__inscription_data_fake = o.inscription_data
			local tal = self:getTalentFromId("T_"..o.inscription_talent.."_1")
			local tal_desc = tal.info(self, tal) --tostring(self:getTalentFullDescription(tal, 1, nil, 1))
			local tal_name = tal.name
			local color = "#PURPLE#"
			self.__inscription_data_fake = nil
			return ([[Use mana-charged steam to invoke your runeplate. You may permanently replace the rune with another by using 'Choose Runeplate' again. Note that this talent will be put on cooldown.
			
			#GOLD#Runeplate Effect:#LAST#
			%s]]):format(tal_desc)
		end
	end,
}

newTalent{
	name = "Explosive Exit", short_name = "REK_DEML_PILOT_EXPLOSIVE_EXIT",
	type = {"steamtech/pilot", 4},
	require = steam_req4,
	points = 5,
	cooldown = function(self, t) return 25 end,
	steam = 5,
	no_npc_use = true,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5)) end,
	radius = 2,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 40, 300) end,
	getDist = function(self, t) return math.floor(self:combatTalentLimit(t, 10, 3, 7)) end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_REK_DEML_RIDE) end,
	action = function(self, t)
		local xx = self.x
		local xy = self.y

		local tg = self:getTalentTarget(t)
		local tx, ty, target = self:getTarget(tg)
		-- jump away from explosion at your old location
		if target and self:canProject(tg, tx, ty) then
			local dist = core.fov.distance(self.x, self.y, tx, ty) + t.getDist(self,t)
			local tgt_dist, move_dist = core.fov.distance(self.x, self.y, tx, ty), t.getDist(self,t)
			
			local block_check = function(_, bx, by)
				return game.level.map:checkEntity(bx, by, Map.TERRAIN, "block_move", self)
			end
			local linestep
			local function check_dest(px, py)
				local check = false
				linestep = self:lineFOV(px, py, block_check, nil, tx, ty)
				local lx, ly, is_corner_blocked
				repeat -- make sure line passes through talent user
					--print("check_dest checking", px, py)
					lx, ly, is_corner_blocked = linestep:step()
					if self.x == lx and self.y == ly then check = true break end
				until is_corner_blocked or not lx or not ly or game.level.map:checkEntity(lx, ly, Map.TERRAIN, "block_move", self)
				return check
			end
			
			local dx, dy
			local l = target:lineFOV(self.x, self.y)
			l:set_corner_block()
			local lx, ly, is_corner_blocked = l:step(true)
			local possible_x, possible_y = lx, ly
			local pass_self = false
			-- Check for terrain and friendly actors
			while lx and ly and not is_corner_blocked and core.fov.distance(self.x, self.y, lx, ly) <= move_dist do
				local actor = game.level.map(lx, ly, engine.Map.ACTOR)
				if actor == self then
					pass_self = true
				elseif pass_self and game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") then
					break
				end
				possible_x, possible_y = lx, ly
				lx, ly = l:step(true)
			end
			
			if pass_self then
				game.target.target.entity = nil
				game.target.target.x = possible_x
				game.target.target.y = possible_y
			end
			
			local tg2 = {type="beam", source_actor=self, selffire=false, range=move_dist, talent=t, no_start_scan=true, no_move_tooltip=true}
			tg2.display_line_step = function(self, d) -- highlight permissible grids for the player
				local t_range = core.fov.distance(self.target_type.start_x, self.target_type.start_y, d.lx, d.ly)
				if t_range >= 1 and t_range <= tg2.range and not d.block and check_dest(d.lx, d.ly) then
					d.s = self.sb
				else
					d.s = self.sr
				end
				d.display_highlight(d.s, d.lx, d.ly)
			end
			dx, dy = self:getTarget(tg2)
			
			
			if not (dx and dy) or not game.level.map:isBound(dx, dy) or core.fov.distance(dx, dy, self.x, self.y) > move_dist then return end
			local allowed = check_dest(dx, dy)
			if not allowed then
				game.logPlayer(self, "You must jump directly away from your target in a straight line.")
				return
			end
			
			local ok_grids = {}
			repeat  -- get list of  allowed grids along path
				local lx, ly, is_corner_blocked = linestep:step()
				if lx and ly then
					if game.level.map:checkEntity(lx, ly, Map.TERRAIN, "block_move", self) then break
					elseif not game.level.map(lx, ly, Map.ACTOR) then
						ok_grids[#ok_grids+1]={lx, ly}
					end
				end
			until is_corner_blocked or not lx or not ly
			
			local act = game.level.map(dx, dy, Map.ACTOR)
			-- abort for known obstacles
			if self:hasLOS(dx, dy) and (game.level.map:checkEntity(dx, dy, Map.TERRAIN, "block_move", self) or act and self:canSee(act)) then
				game.logPlayer(self, "You must land in an empty space.")
				return false
			else -- move to the furthest allowed grid
				local dest_grid = ok_grids[#ok_grids]
				if dest_grid then -- land short
					if dx ~= dest_grid[1] or dy ~= dest_grid[2] then
						game.logPlayer(self, "Your jump was partially blocked.")
					end
				else
					game.logPlayer(self, "You are not able to jump in that direction.")
					return false
				end
			end
			self:move(dx, dy, true)
		else
			xx = tx
			xy = ty
		end

		-- explode
		game.level.map:particleEmitter(xx, xy, self:getTalentRadius(t), "fireflash", {radius=self:getTalentRadius(t)})
		self:project(
			{type="ball", radius=self:getTalentRadius(t), friendlyfire=true, x=xx, y=xy},
			xx, xy,
			function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				DamageType:get(DamageType.FIRE).projector(self, px, py, DamageType.FIRE, t.getDamage(self, t))
			end)
		game:playSoundNear(self, "talents/fire")

		-- Remove effect, start coolingdown
		self:removeEffect(self.EFF_REK_DEML_RIDE)
		self:startTalentCooldown(self.T_REK_DEML_PILOT_AUTOMOTOR, 10)
		return true
	end,
	info = function(self, t)
		return ([[Set a short fuse leading to your ride's fuel tank and jump out.  If you target an adjacent creature, you jump back up to %d grids from your target, leaving your ride behind.  If you target an empty space, your ride moves to the target location while you stay behind. 
Either way, your ride then explodes, dealing %d fire damage in radius %d and putting Steel Rider on a 10 turn cooldown.

#{italic}#When the worst comes to worst, your ride can serve as a final weapon.#{normal}#]]):format(self:getTalentRange(t), damDesc(self, DamageType.FIRE, t.getDamage(self, t)), self:getTalentRadius(t))
	end,
}