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
								game.logSeen(actor, "%s is displaced out of the collapsing wall!", actor.name)
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
		for i = -2, 2 do
		for j = -2, 2 do
			if i ~= 0 or j ~= 0 and ((i ~= 2 and i ~= -2) or (j ~= 2 and j ~= -2)) then
				t.makeHole(self, t, self.x + i, self.y + j)
			end
		end
		end
	end,
	callbackOnMove = function(self, t, moved, forced, ox, oy, x, y)
		if not forced and self.x ~= ox or self.y ~= oy then
			t.carveHoles(self, t)
		end
	end,
	info = function(self, t)
		return ([[Walls within 2 spaces of you become flat ground, and remain passable for 3 turns after you leave.  Creatures that would be left in a wall when you leave are shunted to the closest open space.
Levels in this talent increase your movement speed by %d%%]]):tformat(t.getPassiveSpeed(self, t)*100)
	end
}

newTalent{
	name = "Revel", short_name = "REK_HEKA_SYBARITE_REVEL",
	type = {"spell/sybarite", 2},	require = mag_req2, points = 5,
	mode = "passive",
	getOverwatch = function(self, t) return self:combatTalentScale(t, 1, 5) end,
	--used in an effect applied in the eye's stare down talent via the STARE damage type
	info = function(self, t)
		return ([[Rest easy knowing that someone is watching your back, even if that someone is you.  When you are in the area of an Evil Eye, your health regeneration is increased by %d and your saves by %d.]]):tformat(t.getOverwatch(self, t), t.getOverwatch(self, t)*8)
	end,
}

newTalent{
	name = "BE KNELT", short_name = "REK_HEKA_SYBARITE_KNEEL",
	type = {"spell/sybarite", 3}, require = mag_req3, points = 5,
	mode = "passive",
	getMultiplier = function(self, t) return math.max(1, self:combatTalentLimit(t, 5, 1.5, 2.25)) end,
	-- handled in the STARE damage type
	info = function(self, t)
		return ([[If an enemy is affected by multiple Evil Eyes in one turn, the damage will be increased by %d%% and the slow by %d%%.]]):tformat(t.getMultiplier(self, t)*200-100, t.getMultiplier(self, t)*100)
	end,
}


newTalent{
	name = "On Parade", short_name = "REK_HEKA_SYBARITE_PARADE",
	type = {"spell/sybarite", 4}, require = mag_req4, points = 5,
	mode = "passive",
	getDamageChange = function(self, t) return self:combatTalentLimit(t, 75, 20, 66) end,
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
			local potential = dam * t.getDamageChance(self, t)/100
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

#{italic}#No army could defeat you.  Only a lone champion has a chance of victory.#{normal}#]]):tformat(t.getDamageChange(self, t)/3)
	end,
}
