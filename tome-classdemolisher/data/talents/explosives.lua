local Trap = require "mod.class.Trap"
local Object = require "mod.class.Object"


newTalent{
   name = "Detonator", short_name = "REK_DEML_EXPLOSIVE_DETONATE",
   type = {"steamtech/other", 1},
   require = steam_req1,
   points = 5,
   cooldown = 0,
	 action = function(self, t)
		 local detonated = 0
		 self:project(
			 {type="ball", range=0, radius=10, no_restrict=true},
			 self.x, self.y,
			 function(px, py)
				 local trap = game.level.map(px, py, engine.Map.TRAP)
				 if not trap then return end
				 if trap.name ~= "remote explosive charge" then return end
				 if trap.summoner ~= self then return end
				 trap:triggered(px, py, self)
				 detonated = detonated + 1
			 end)
		 if self:knowTalent(self.T_REK_DEML_PYRO_BLASTRIDER) and detonated >= 3 then
			 self:callTalent(self.T_REK_DEML_PYRO_BLASTRIDER, "gainSpeed")
		 end
		 return true
   end,
   info = function(self, t)
      return ([[Detonate all of your explosive charges within range 10.]]):format()
   end,
}

newTalent{
	name = "Explosive Charge", short_name = "REK_DEML_EXPLOSIVE_REMOTE_CHARGE",
	type = {"steamtech/explosives", 1},
	require = steam_req1,
	points = 5,
	on_learn = function(self, t)
		self:learnTalent(self.T_REK_DEML_EXPLOSIVE_DETONATE, true, nil, {no_unlearn=true})
	end,
	on_unlearn = function(self, t)
		self:unlearnTalent(self.T_REK_DEML_EXPLOSIVE_DETONATE)
	end,
	steam = function(self, t)
		local cost = 10
		if self:isTalentActive(self.T_REK_DEML_PYRO_FLAMES) then cost  = cost + 5
			return cost
		end
	end,
	cooldown = 0,
	range = 6,
	radius = 1,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 50, 500) end,
	placeCharge = function(self, t, x, y)
		local dam = self:steamCrit(t.getDamage(self, t))
		local burn = 0
		if self:isTalentActive(self.T_REK_DEML_PYRO_FLAMES) then
			burn = self:callTalent(self.T_REK_DEML_PYRO_FLAMES, "getDamage")
		end
		local trap = Trap.new{
			name = "remote explosive charge",
			type = "steamtech", id_by_type=true, unided_name = "trap",
			display = '#', color=colors.ORANGE, image = "trap/critical_steam_engine.png",
			dam = dam,
			radius = self:getTalentRadius(t),
			canTrigger = function(self, x, y, who) return false end,
			triggered = function(self, x, y, who)
				local DamageType = require "engine.DamageType"
				-- Mayhem engine CDR
				if who and who:knowTalent(who.T_REK_DEML_BATTLEWAGON_MAYHEM_ENGINE) and not who:hasProc("demolisher_mayhem") then
					who:setProc("demolisher_mayhem", true, 1)
					local cd = who:callTalent(who.T_REK_DEML_BATTLEWAGON_MAYHEM_ENGINE, "getCDReduce")
					if who:isTalentCoolingDown(who.T_REK_DEML_ENGINE_RAMMING_SPEED) then
						who:alterTalentCoolingdown(who.T_REK_DEML_ENGINE_RAMMING_SPEED, -cd)
					end
					if who:isTalentCoolingDown(who.T_REK_DEML_MG_MISSILE) then
						who:alterTalentCoolingdown(who.T_REK_DEML_MG_MISSILE, -cd)
					end
					if who:isTalentCoolingDown(who.T_REK_DEML_MG_GAUSS) then
						who:alterTalentCoolingdown(who.T_REK_DEML_MG_GAUSS, -cd)
					end
					if who:isTalentCoolingDown(who.T_REK_DEML_MG_HARPOON) then	 
						who:alterTalentCoolingdown(who.T_REK_DEML_MG_HARPOON, -cd)
					end
				end
				
				game.level.map:particleEmitter(self.x, self.y, self.radius, "fireflash", {radius=self.radius})
				-- damage
				local tg = {type="ball", radius=self.radius, friendlyfire=false, x=self.x, y=self.y},
				self.summoner:project(
					{type="ball", radius=self.radius, friendlyfire=false, x=self.x, y=self.y}, self.x, self.y,
					function(px, py)
						local target = game.level.map(px, py, engine.Map.ACTOR)
						if not target then return end
						DamageType:get(DamageType.REK_DEML_FIRE_DIMINISHING).projector(self.summoner, px, py, DamageType.REK_DEML_FIRE_DIMINISHING, self.dam)
					end)
				if self.burn > 0 then
					self.summoner:project(tg, self.x, self.y, DamageType.FIREBURN, {dam=self.burn, dur=4, initial=0})
				end
				game:playSoundNear(self, "talents/fire")
				game.level:removeEntity(self)
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
				return true
			end,
			temporary = 10,
			x = x, y = y,
			disarm_power = math.floor(self:combatSteampower() * 1.8),
			detect_power = math.floor(self:combatSteampower() * 1.8),
			burn = burn,
			canAct = false,
			energy = {value=0},
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level:removeEntity(self)
					if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
				end
			end,
			summoner = self,
			summoner_gain_exp = true,
		}
		game.level:addEntity(trap)
		trap:identify(true)
		trap:setKnown(self, true)
		game.zone:addEntity(game.level, trap, "trap", x, y)
	end,
	action = function(self, t)
		local tg = {type="ball", radius=self:getTalentRadius(t), nowarning=true, range=self:getTalentRange(t), nolock=true, talent=t}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		if game.level.map:checkEntity(tx, ty, Map.TERRAIN, "block_move") then return end
		local trap = game.level.map(tx, ty, Map.TRAP)
		if trap then
			game.logPlayer(self, "There's already a trap there.")
			return
		end

		t.placeCharge(self, t, tx, ty)
		
		return true
	end,
	info = function(self, t)
		return ([[Throw a small bundle of explosives onto the battlefield that is primed for you to detonate at a later time.
When triggered, the device creates a blast in radius 1, hitting all foes for %0.2f fire damage.  Targets take 40%% reduced damage from each remote charge after the first that hits them in a turn.
Steampower: increases damage

Undetonated charges disarm after 10 turns.]]):format(damDesc(self, DamageType.FIRE, t.getDamage(self, t)))
	end,
}

makeMine = function(self, t, x, y, dam)
	-- Mine values
	local duration = self:callTalent(self.T_REK_DEML_EXPLOSIVE_MINELAYER, "getDuration")
	local detect = math.floor(self:callTalent(self.T_REK_DEML_EXPLOSIVE_MINELAYER, "getTrapPower") * 0.8)
	local disarm = math.floor(self:callTalent(self.T_REK_DEML_EXPLOSIVE_MINELAYER, "getTrapPower"))
	local power = self:combatSteampower()
	
	-- Our Mines
	local mine = Trap.new{
		name = "blast mine",
		type = "steamtech", id_by_type=true, unided_name = "trap",
		display = '^', color=colors.ORANGE, image = ("trap/chronomine_red_0%d.png"):format(rng.avg(1, 4, 3)),
		shader = "shadow_simulacrum", shader_args = { color = {0.2, 0.2, 0.2}, base = 0.8, time_factor = 1500 },
		temporary = duration,
		x = x, y = y,
		faction = self.faction,
		summoner = self, summoner_gain_exp = true,
		disarm_power = disarm,	detect_power = detect,
		dam = dam, talent=t, power = power,
		canTrigger = function(self, x, y, who)
			if who:reactionToward(self.summoner) < 0 then return mod.class.Trap.canTrigger(self, x, y, who) end
			return false
		end,
		triggered = function(self, x, y, who)
			-- Project our damage
			self.summoner:project({type="hit",x=x,y=y, talent=self.talent}, x, y, engine.DamageType.FIRE, self.dam/2)
			self.summoner:project({type="hit",x=x,y=y, talent=self.talent}, x, y, engine.DamageType.PHYSICALBLEED, self.dam/2)

			-- knockback
			if not who.dead then
				local hit = self.summoner:checkHit(self.power, who:combatPhysicalResist()) and who:canBe("knockback")
				if hit then
					local direction = rng.table({0,1,2,3,5,6,7,8})
					local dx = direction % 3 - 1
					local dy = math.floor(direction/3) - 1
					who:knockback(who.x+dx, who.y+dy, 1)
				end
				if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
				game.level:removeEntity(self)
			end
			
			return true, true
		end,
		canAct = false,
		energy = {value=0},
		act = function(self)
			self:useEnergy()
			self.temporary = self.temporary - 1
			if self.temporary <= 0 then
				if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
				game.level:removeEntity(self)
			end
		end,
	}
	
	return mine
end

newTalent{
	name = "Minelayer", short_name = "REK_DEML_EXPLOSIVE_MINELAYER",
	type = {"steamtech/explosives", 2},
	require = steam_req2,
	points = 5,
	cooldown = 10,
	steam = 20,
	tactical = { ATTACKAREA = { FIRE = 1, PHYSICAL = 1 }, ESCAPE = 2  },
	requires_target = true,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2)) end,
	range = function(self, t) return math.min(8, math.floor(self:combatTalentScale(t, 4, 8, 0.5, 0, 1))) end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 200) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	getTrapPower = function(self,t) return math.max(1,self:combatScale(self:getTalentLevel(t) * self:getCun(15, true), 0, 0, 75, 75)) end, 
	target = function(self, t) return {type="ball", nowarning=true, range=self:getTalentRange(t), radius=self:getTalentRadius(t), nolock=true, talent=t} end,	
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		
		-- Lay the mines in a ball
		local dam = self:steamCrit(t.getDamage(self, t))
		self:project(
			tg, tx, ty,
			function(px, py)
				local target_trap = game.level.map(px, py, Map.TRAP)
				if target_trap then return nil end
				if game.level.map:checkEntity(px, py, Map.TERRAIN, "block_move") then return end
				
				-- Make our mine
				local trap = makeMine(self, t, px, py, dam)				
				-- Add the mine
				game.level:addEntity(trap)
				trap:identify(true)
				trap:setKnown(self, true)
				game.zone:addEntity(game.level, trap, "trap", px, py)
			end)
		game:playSoundNear(self, "talents/warp")
		
		return true
	end,
	info = function(self, t)
		return ([[Lay Blast Mines in a radius of %d that inflict %0.2f physical (bleed) and %0.2f fire damage and knock enemies 1 space in a random direction (#SLATE#Steampower vs. Physical#LAST#).
		The mines are hidden traps (%d detection and %d disarm power based on your Cunning) and last for %d turns.
Steampower: improves damage.]]):
		format(self:getTalentRadius(t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)*1.5/2), damDesc(self, DamageType.FIRE, t.getDamage(self, t)/2), t.getTrapPower(self, t)*0.8, t.getTrapPower(self, t), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Self-Destruct", short_name = "REK_DEML_SPIDER_MINE_EXPLODE",
	image = "talents/rek_deml_explosive_spider_mine.png",
	type = {"steamtech/other", 1},
	points = 5,
	cooldown = 2,
	tactical = { ATTACK = { weapon = 2 } },
	requires_target = true,
	callbackOnDeath = function(self, t, src, death_note)
		if self.exploded then return end
		if self.summoner and self.summoner:knowTalent(self.T_REK_DEML_BATTLEWAGON_MAYHEM_ENGINE) then
			local cd = self.summoner:callTalent(self.summoner.T_REK_DEML_BATTLEWAGON_MAYHEM_ENGINE, "getCDReduce")
			if self.summoner:isTalentCoolingDown(self.summoner.T_REK_DEML_ENGINE_RAMMING_SPEED) then
				self.summoner:alterTalentCoolingdown(self.summoner.T_REK_DEML_ENGINE_RAMMING_SPEED, -cd)
			end
			if self.summoner:isTalentCoolingDown(self.summoner.T_REK_DEML_MG_MISSILE) then
				self.summoner:alterTalentCoolingdown(self.summoner.T_REK_DEML_MG_MISSILE, -cd)
			end
			if self.summoner:isTalentCoolingDown(self.summoner.T_REK_DEML_MG_GAUSS) then
				self.summoner:alterTalentCoolingdown(self.summoner.T_REK_DEML_MG_GAUSS, -cd)
			end
			if self.summoner:isTalentCoolingDown(self.summoner.T_REK_DEML_MG_HARPOON) then	 
				self.summoner:alterTalentCoolingdown(self.summoner.T_REK_DEML_MG_HARPOON, -cd)
			end
		end
		self.exploded = true
		local rad = self.blast_rad or 2
		local dam = self.blast_dam or 100
		game.level.map:particleEmitter(self.x, self.y, self.radius, "fireflash", {radius=rad})
		local tg = {type="ball", radius=rad, friendlyfire=true, x=self.x, y=self.y}

		local old_ps = self.summoner.__project_source
		self.summoner.__project_source = self
		self.summoner:project(
			tg,	self.x, self.y,
			function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				DamageType:get(DamageType.FIRE).projector(self.summoner, px, py, DamageType.FIRE, dam)
			end)
		if self.burn > 0 then
			self.summoner:project(tg, self.x, self.y, DamageType.FIREBURN, {dam=self.burn, dur=4, initial=0})
		end
		self.summoner.__project_source = old_ps
		game:playSoundNear(self, "talents/fire")
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		
		self:die()
		
		return true
	end,
	info = function(self, t)
		return ([[Blow yourself up.]]):format()
	end,
}

newTalent{
	name = "Mecharachnid Mine", short_name = "REK_DEML_EXPLOSIVE_SPIDER_MINE",
	type = {"steamtech/explosives", 3},
	require = steam_req3,
	points = 5,
	cooldown = 12,
	steam = function(self, t)
		local cost = 15
		if self:isTalentActive(self.T_REK_DEML_PYRO_FLAMES) then cost  = cost + 5
			return cost
		end
	end,
	range = 1,
	tactical = { ATTACK = { FIRE = 2 } },
	requires_target = true,
	radius = 3,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), nolock=true, default_target=self, first_target="friend", talent=t}
	end,
	getMovementSpeed = function(self, t) return self:combatTalentScale(t, 2, 5) end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 40, 300) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local act = game.level.map(x, y, Map.ACTOR)
		local block = game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move")
		if block or act then return nil end

		--local x, y = util.findFreeGrid(self.x, self.y, 1, true, {[Map.ACTOR]=true})
		--if not x then return nil end
		
		local burn = 0
		if self:isTalentActive(self.T_REK_DEML_PYRO_FLAMES) then
			burn = self:callTalent(self.T_REK_DEML_PYRO_FLAMES, "getDamage")
		end
		
		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "mechanical", subtype = "arachnid",
			display = "S", blood_color = colors.ORANGE,
			faction = self.faction,
			repairable=true,
			stats = { str=10, dex=50, wil=1, mag=5, con=20, cun=10 },
			infravision = 10,
			no_breath = 1,
			fear_immune = 1,
			sight = 15,
			infravision = 15,
			name = "Mecharachnid Mine", color=colors.ORANGE,
			desc = "A swift mechanical spider carrying an unstable explosive",
			image = "npc/mechanical_arachnid_mecharachnid_repairbot.png",
			level_range = {self.level, self.level}, exp_worth = 0,
			rank = 2,
			size_category = 1,
			autolevel = "zerker",
			max_life = 100,
			life_rating = 4,
			life_regen = 4,
			movement_speed = t.getMovementSpeed(self, t),
			blast_rad = self:getTalentRadius(t),
			blast_dam = t.getDamage(self, t),
			burn = burn,
			combat_armor = 16, combat_def = 1,
			combat = { dam=10 + self.level, atk=self.level*2.2, apr=0, dammod={str=1.1}, physcrit = 10 },
			
			resolvers.talents{
				[Talents.T_REK_DEML_SPIDER_MINE_EXPLODE]=1,			
											 },
			
			ai = "summoned", ai_real = "tactical", ai_state = { ai_move="move_complex", talent_in=1, ally_compassion=0 },
			no_drops = true, keep_inven_on_death = false,
			faction = self.faction,
			summoner = self,
			summoner_gain_exp=true,
			summon_time = 10,
										 }
		m:resolve()
		m:resolve(nil, true)
		
		game.zone:addEntity(game.level, m, "actor", x, y)
		if target then m:setTarget(target) end
		
		if game.party:hasMember(self) then
			m.remove_from_party_on_death = true
			game.party:addMember(m, {
														 control=false,
														 temporary_level = true,
														 type="summon",
														 title="Summon",
															})
		end
		return true
	end,
	info = function(self, t)
		return ([[Deploy a miniature mecharachnid to carry an explosive into position.  It has %d%% movement speed.
When it reaches an enemy or dies, the mecharachnid will explode, dealing %d fire damage in radius %d.
]]):format(t.getMovementSpeed(self, t)*100, damDesc(self, DamageType.FIRE, t.getDamage(self, t)), self:getTalentRadius(t))
	end,
}

newTalent{
	name = "Mad Bomber", short_name = "REK_DEML_EXPLOSIVE_MAD_BOMBER",
	type = {"steamtech/explosives", 4},
	require = steam_req4,
	points = 5,
	mode = "sustained",
	cooldown = 5,
	drain_steam = 2,
	range = function(self, t) return 8 end,
	radius = function(self, t) return 1 end,
	target = function(self, t) return {type="ball", radius=0, range=self:getTalentRange(t), talent=t} end,
	getBombCD = function(self, t) return math.max(3, self:combatTalentScale(t, 10, 4)) end,
	callbackOnCrit = function(self, t, kind)
		if kind ~= "steam" then return nil end
		local p = self:isTalentActive(self.T_REK_DEML_EXPLOSIVE_MAD_BOMBER)
		if not p then return nil end
		local t1 = self:getTalentFromId(self.T_REK_DEML_EXPLOSIVE_REMOTE_CHARGE)
		if not t1 then return nil end
		
		local cd = self:hasProc("mad_bomber")
		if cd and cd.turns then
			self:setProc("mad_bomber", true, cd.turns-1)
			return nil
		end
	
		-- collect spaces of or adjacent to enemies within range that don't already have a charge
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do
			for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, Map.ACTOR)
				if a and self:reactionToward(a) < 0 then
					local subgrids = core.fov.circle_grids(a.x, a.y, 1, true)
					local valid = false
					for sx, syy in pairs(subgrids) do
						for sy, _ in pairs(subgrids[sx]) do
							local t = game.level.map(sx, sy, Map.TRAP)
							if (not t or t.name ~= "remote explosive charge") and not game.level.map:checkEntity(px, py, Map.TERRAIN, "block_move") then
								tgts[#tgts+1] = {x=sx, y=sy}
							end
						end
					end
				end
			end
		end
		if #tgts < 1 then return nil end
		local target = rng.tableRemove(tgts)

		if not self:canProject(tg, target.x, target.y) then return nil end
		t1.placeCharge(self, t1, target.x, target.y)
		
		self:setProc("mad_bomber", true, t.getBombCD(self, t))
		return true
	end,
	activate = function(self, t)
		local ret = {}
		if core.shader.active() then
			ret.particle1 = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=0, radius=0.8, img="runicshield_yellow"}, {type="lightningshield", time_factor=3000, noup=1.0}))
			ret.particle1.toback = true
			ret.particle2 = self:addParticles(Particles.new("shader_ring_rotating", 1, {rotation=0, radius=0.8, img="runicshield_dark"}, {type="lightningshield", time_factor=3000, noup=1.0}))
		end
		return ret
	end,
	deactivate = function(self, t, p)
		if p.particle1 then self:removeParticles(p.particle1) end
		if p.particle2 then self:removeParticles(p.particle2) end
		return true
	end,
	info = function(self, t)
		return ([[When one of your steam abilities goes critical, you throw an extra explosive charge towards a random target in range %d.
This can only happen every %d game turns.  Extra criticals reduce the cooldown by one turn.
		]]):format(self:getTalentRange(t), t.getBombCD(self, t))
	end,
}