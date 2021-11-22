local Object = require "mod.class.Object"

--displaces an actor to the nearest walkable tile in the specified radius
function road_displaceActor (actor, r)
	local tiles = {}
	local shortest_dist = r
	for i = actor.x-r, actor.x+r do
	for j = actor.y-r, actor.y+r do
		local dist = core.fov.distance(actor.x, actor.y, i, j)
		if game.level.map:isBound(i, j) and	dist <= shortest_dist and actor:canMove(i, j) then
			-- Check for no_teleport and vaults
			if game.level.map.attrs(i, j, "no_teleport") then
				local vault = game.level.map.attrs(actor.x, actor.y, "vault_id")
				if vault and game.level.map.attrs(i, j, "vault_id") == vault then
					tiles[#tiles+1] = {x=i,y=j,dist=dist}
					shortest_dist = math.min(shortest_dist, dist)
				end
			else
				tiles[#tiles+1] = {x=i,y=j,dist=dist}
				shortest_dist = math.min(shortest_dist, dist)
			end
		end
	end
	end
	local close_tiles = {}
	for i = 1, #tiles do
		if tiles[i].dist <= shortest_dist then
			close_tiles[#close_tiles+1] = tiles[i]
		end
	end
	tiles = close_tiles
	
	if #tiles > 0 then
		local tile = tiles[rng.range(1, #tiles)]
		actor:move(tile.x, tile.y, true)
		
		return true
	end
end

newTalent{
	name = "Royal Road", short_name = "REK_HEKA_SYBARITE_ROYAL_ROAD",
	type = {"spell/sybarite", 1}, require = mag_req1, points = 5,
	mode = "passive",
	no_unlearn_last = true,
	range = 2,
	getPassiveSpeed = function(self, t) return self:combatTalentScale(t, 0.08, 0.4, 0.7) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "movement_speed", t.getPassiveSpeed(self, t))
	end,
	makeHole = function(self, t, x, y)
		if not game.level.map:isBound(x, y) then return end
		local oe = game.level.map(x, y, Map.TERRAIN)
		if not oe or oe.special then return end
		if not oe or oe:attr("temporary") or not oe.dig or not game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move") then return end
		local e = Object.new{
			old_feat = oe,
			name = oe.name, image = oe.image,
			desc = oe.desc,
			type = oe.type,
			display = oe.display, color=colors.WHITE, back_color=colors.BLACK,
			show_tooltip = true,
			block_sight = false,
			temporary = true,
			timeout = 3,
			x = x, y = y,
			canAct = false,
			add_displays = oe.add_displays,
			add_mos = oe.add_mos,
			displace = road_displaceActor,
			act = function(self)
				local Map = require "engine.Map"
				self:useEnergy()
				if core.fov.distance(self.x, self.y, self.summoner.x, self.summoner.y) > 2 then
					self.timeout = self.timeout - 1
					if self.timeout <= 0 then
						if self.particles then game.level.map:removeParticleEmitter(self.particles) end
						game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
						game.level:removeEntity(self)
						
						--move actors on the collapsing tile away
						local actor = game.level.map(self.x, self.y, Map.ACTOR)
						if actor then
							if not actor.turn_procs.road_displaced then
								actor.turn_procs.road_displaced = true
								game.logSeen(actor, "%s is displaced out of the reforming wall!", actor.name)
							end
							self.displace(actor, 100)
						end
						
						game.level.map:updateMap(self.x, self.y)
						game.nicer_tiles:updateAround(game.level, self.x, self.y)
					end
				end
			end,
			summoner_gain_exp = true,
			summoner = self,
		}
		e.tooltip = mod.class.Grid.tooltip
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN, e)
		--game.level.map:updateMap(x, y)
		e.particles = Particles.new("royal_road", 1, {})
		e.particles.x = x
		e.particles.y = y
		game.level.map:addParticleEmitter(e.particles)
	end,
	carveHoles = function(self, t)
		local tg = {type="ball", range=0, radius=self:getTalentRange(t), talent=t}
		local grids = self:project(
			tg, self.x, self.y,
			function(tx, ty)
				t.makeHole(self, t, tx, ty)
			end
		)
		-- for i = -2, 2 do
		-- 	for j = -2, 2 do
		-- 		if i ~= 0 or j ~= 0 and ((i ~= 2 and i ~= -2) or (j ~= 2 and j ~= -2)) then
		-- 			t.makeHole(self, t, self.x + i, self.y + j)
		-- 		end
		-- 	end
		-- end
	end,
	callbackOnMove = function(self, t, moved, forced, ox, oy, x, y)
		if not forced and self.x ~= ox or self.y ~= oy then
			t.carveHoles(self, t)
		end
	end,
	info = function(self, t)
		return ([[Diggable walls within 2 spaces of you become flat ground, and remain passable for 3 turns after you leave.  Creatures that would be left in a wall when you leave are shunted to the closest open space.
Levels in this talent increase your movement speed by %d%%]]):tformat(t.getPassiveSpeed(self, t)*100)
	end
}

newTalent{
	name = "The Arena", short_name = "REK_HEKA_SYBARITE_REVEL",
	type = {"spell/sybarite", 2},	require = mag_req2, points = 5,
	cooldown = 20,
	fixed_cooldown = true,
	hands = 5,
	tactical = {BUFF = 1},
	range = 8,
	getDuration = function(self, t) return 8 end,
	getDamage = function(self, t) return self:combatTalentScale(t, 25, 100) end,
	getResist = function(self, t) return self:combatTalentLimit(t, 35, 10, 25) end,
	makeHole = function(self, t, x, y)
		local duration = t.getDuration(self, t)
		local oe = game.level.map(x, y, Map.TERRAIN)
		local e = Object.new{
			old_feat = oe,
			name = oe.name, image = oe.image,
			desc = oe.desc,
			type = oe.type,
			display = oe.display, color=colors.WHITE, back_color=colors.BLACK,
			show_tooltip = true,
			block_sight = false,
			temporary = true,
			timeout = duration,
			x = x, y = y,
			canAct = false,
			add_displays = oe.add_displays,
			add_mos = oe.add_mos,
			displace = road_displaceActor,
			act = function(self)
				local Map = require "engine.Map"
				self:useEnergy()
				if core.fov.distance(self.x, self.y, self.summoner.x, self.summoner.y) > 2 then
					self.timeout = self.timeout - 1
					if self.timeout <= 0 then
						if self.particles then game.level.map:removeParticleEmitter(self.particles) end
						game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
						game.level:removeEntity(self)
						
						--move actors on the collapsing tile away
						local actor = game.level.map(self.x, self.y, Map.ACTOR)
						if actor then
							if not actor.turn_procs.road_displaced then
								actor.turn_procs.road_displaced = true
								game.logSeen(actor, "%s is displaced out of the reforming wall!", actor.name)
							end
							self.displace(actor, 100)
						end
						
						game.level.map:updateMap(self.x, self.y)
						game.nicer_tiles:updateAround(game.level, self.x, self.y)
					end
				end
			end,
			summoner_gain_exp = true,
			summoner = self,
		}
		e.tooltip = mod.class.Grid.tooltip
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN, e)
		--game.level.map:updateMap(x, y)
		e.particles = Particles.new("royal_road", 1, {})
		e.particles.x = x
		e.particles.y = y
		game.level.map:addParticleEmitter(e.particles)
	end,
	action = function(self, t)
		local tg = {type="ball", range=0, radius=self:getTalentRange(t), talent=t}
		local countWalls = 0
		local grids = self:project(
			tg, self.x, self.y,
			function(tx, ty)
				if not game.level.map:isBound(tx, ty) then return end
				local oe = game.level.map(tx, ty, Map.TERRAIN)
				if not oe or oe.special then return end
				if not oe or oe:attr("temporary") or not oe.dig or not game.level.map:checkEntity(tx, ty, engine.Map.TERRAIN, "block_move") then return end
				countWalls = countWalls + 1
				t.makeHole(self, t, tx, ty)
			end
		)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_physical", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y})
		self:setEffect(self.EFF_REK_HEKA_ARENA, t.getDuration(self, t), {damageMax=t.getDamage(self, t), resistMax=t.getResist(self, t), walls=countWalls, src=self})
		--todo sound
		--todo visual
		return true
	end,
	info = function(self, t)
		return ([[Extend the royal road outward, making walls within range %d passable for %d turns.  During this time you grow 1 size category and gain up to +%d%% damage and +%d%% resistance, based on the number of walls flattened.

#{italic}#No lures, tunnels, nor ambushes.  Fight your enemy in glorious open combat!#{normal}#]]):tformat(self:getTalentRange(t), t:_getDuration(self), t:_getDamage(self), t:_getResist(self))
	end,
}

newTalent{
	name = "Be Knelt", short_name = "REK_HEKA_SYBARITE_KNEEL",
	type = {"spell/sybarite", 3}, require = mag_req3, points = 5,
	cooldown = 15,
	fixed_cooldown = true,
	hands = 30,
	tactical = {DISABLE = 4},
	range = 2,
	target = function(self, t)
		return {type="ball", range=0, radius=self:getTalentRange(t), talent=t}
	end,
	getLoss = function(self, t) return self:combatTalentLimit(t, 2.0, 0.4, 1.5) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		self:project(
			tg, self.x, self.y,
			function(px, py)
				local target = game.level.map(px, py, Map.ACTOR)
				if target and self:reactionToward(target) <= 0 then
					target.energy.value = target.energy.value - game.energy_to_act * t:_getLoss(self)
					game.level.map:particleEmitter(px, py, 1, "image_rise", {img="heka_knelt"})
				end
			end
		)
		return true
	end,
	info = function(self, t)
		return ([[Briefly unveil your full presence, and enemies within range %d are cast down, losing %d%% of a turn (#SLATE#no save#LAST#).]]):tformat(self:getTalentRange(t), t:_getLoss(self)*100)
	end,
}

newTalent{
	name = "On Parade", short_name = "REK_HEKA_SYBARITE_PARADE",
	type = {"spell/sybarite", 4}, require = mag_req4, points = 5,
	mode = "passive",
	getDamageChange = function(self, t) return self:combatTalentLimit(t, 75, 28, 66) end,
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, tmp, no_martyr)
		local countFoes = 0
		local grids = core.fov.circle_grids(self.x, self.y, 10, true)
		for x, yy in pairs(grids) do
			for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, Map.ACTOR)
				if a and self:reactionToward(a) < 0 and not a.summoner and not a.temporary then
					countFoes = countFoes + 1
				end
			end
		end
		if countFoes > 1 then
			local views = countFoes - 1
			local potential = dam * t.getDamageChange(self, t)/100
			local absorbed = 0
			for i=1, views do
				absorbed = absorbed + potential / 3
				potential = potential - potential / 3
			end
			game:delayedLogDamage(src, self, 0, ("#WHITE#(%d to parade)#LAST#"):format(absorbed), false)
			dam = dam - absorbed
		end
		return {dam=dam}
	end,
	info = function(self, t)
		return ([[If you can see more than one non-summoned enemy, you gain a barrier that blocks %d%% of incoming damage.  Each additional enemy adds another barrier that is 2/3 as strong as the previous one.

1 Enemy: Nothing
2 Enemies: %d%%
3 Enemies: %d%%
4 Enemies: %d%%
5 Enemies: %d%%
6 Enemies: %d%%
etc.

#{italic}#No army could defeat you.  Only a lone champion has a chance of victory.#{normal}#]]):tformat(t.getDamageChange(self, t)/3, t.getDamageChange(self, t)/3, t.getDamageChange(self, t)*5/9, t.getDamageChange(self, t)*19/27, t.getDamageChange(self, t)*65/81, t.getDamageChange(self, t)*211/244)
	end,
}
