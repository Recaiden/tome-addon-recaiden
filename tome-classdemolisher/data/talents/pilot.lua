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
	no_unlearn_last = true,
	autolearn_talent = "T_HULL_POOL",
	tactical = {SPECIAL = 10},
	getHull = function(self, t) return self.getMaxHull and self:getMaxHull() or 100 end,
	getHullBoost = function(self, t) return self:combatTalentScale(t, 10, 50) end,
	getPinImmune = function(self, t) return math.min(1, self:combatTalentScale(t, 0.1, 0.90, 0.5)) end,
	on_pre_use = function(self, t, silent)
		if self:getInven("BODY") then 
			local am = self:getInven("BODY")[1] or {}
			if am.subtype == "massive" then
				if not silent then
					game.logPlayer(self, "You can't operate your ride in massive armor.")
				end
				return false
			end
		end
		return not self:hasEffect(self.EFF_REK_DEML_RIDE)
	end,
	on_learn = function(self, t)
		local level = self:getTalentLevelRaw(t)
		if level == 1 then
			self.hull_rating = 5
			if self.life_rating >= 7 then --tougher races need tougher cars
				local excess = math.floor((self.life_rating - 5) / 2)
				self.life_rating = self.life_rating - excess
				self.hull_rating = self.hull_rating + excess
			end
		end
		updateSteelRider(self)
	end,
	on_unlearn = function(self, t)
		updateSteelRider(self)
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "max_hull", t.getHullBoost(self,t))
	end,
	action = function(self, t)
		self:incHull(self:getMaxHull())
		self:setEffect(self.EFF_REK_DEML_RIDE, 10, {src=self})
		updateSteelRider(self)
		game:playSoundNear(self, "talents/clinking")
		return true
	end,
	info = function(self, t)
		return ([[You travel in a peculiar contraption: a steam-powered, jet propelled, armored buggy.  While riding, you have %d%% resistance to pinning, and your vehicle's Hull protects you. Damage and Healing are applied to Hull before they are applied to your life.  Hull is based on level (5 life rating), Constitution (2 Hull/point), Willpower (4 Hull/point), and ranks in this talent (+%d Hull).

Controlling your ride requires fine control that isn't possible while wearing massive armor.

(Cancel the effect if you need to get off your ride early)]]):tformat(t.getPinImmune(self, t)*100, t.getHullBoost(self, t))
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
	on_learn = function(self, t) updateSteelRider(self) end,
	on_unlearn = function(self, t) updateSteelRider(self) end,
	is_heal = true,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(self:steamCrit(t.getHeal(self, t)), self)
		self:attr("allow_on_heal", -1)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healarcane", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, beamColor1={0x8e/255, 0x2f/255, 0xbb/255, 1}, beamColor2={0xe7/255, 0x39/255, 0xde/255, 1}, circleDescendSpeed=4}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healarcane", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, beamColor1={0x8e/255, 0x2f/255, 0xbb/255, 1}, beamColor2={0xe7/255, 0x39/255, 0xde/255, 1}, circleDescendSpeed=4}))
		end
		
		game:playSoundNear(self, {"ambient/town/town_large2", vol=200}) -- Hammer clinking sound
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return ([[Make some battlefield repairs to your ride, healing it for %d hull.
The hull restored increases with Steampower and can be a critical hit.
In combat, excess healing to your hull becomes a temporary barrier.
Your familiarity with repairs lets you reinforce the vehicle's structure.  While riding, you have %d extra armor.]]):tformat(t.getHeal(self, t), t.getArmor(self, t))
	end,
}

newTalent{
	name = "Rev Up", short_name = "REK_DEML_PILOT_REV_UP",
	type = {"steamtech/pilot", 3},
	require = steam_req3,
	points = 5,
	steam = 30,
	no_energy = true,
	cooldown = 30,
	tactical = {BUFF = 1},
	getPower = function(self, t) return self:combatTalentScale(t, 0.1, 0.2) end,
	getDuration = function(self, t) return self:combatTalentScale(t, 3, 6) end,
	action = function(self, t)
		self:setEffect(self.EFF_REK_DEML_REVVED_UP, t.getDuration(self, t), {power=t.getPower(self,t), src=self})
		game:playSoundNear(self, "talents/speedup_saw")
		return true
	end,
	info = function(self, t) 
		return ([[Use a rush of steam to overclock your motors and mechanisms.  For %d turns, your steam speed is increased by %d%%, your guardian drone can block %d%% more damage, and your gunner drone has a %d%% chance to fire twice.]]):tformat(t.getDuration(self, t), t.getPower(self,t)*100, t.getPower(self,t)*100, t.getPower(self,t)*100) 
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
	range = function(self, t) return math.floor(self:combatTalentScale(t, 4, 6)) end,
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
		self:startTalentCooldown(self.T_REK_DEML_PILOT_AUTOMOTOR, 10)
		self:removeEffect(self.EFF_REK_DEML_RIDE)
		return true
	end,
	info = function(self, t)
		return ([[Set a short fuse leading to your ride's fuel tank and jump out.  If you target an adjacent creature, you jump back up to %d grids from your target, leaving your ride behind.  If you target an empty space, your ride moves to the target location while you stay behind. 
Either way, your ride then explodes, dealing %d fire damage in radius %d and putting Steel Rider on a 10 turn cooldown.

#{italic}#When the worst comes to worst, your ride can serve as a final weapon.#{normal}#]]):tformat(self:getTalentRange(t), damDesc(self, DamageType.FIRE, t.getDamage(self, t)), self:getTalentRadius(t))
	end,
}