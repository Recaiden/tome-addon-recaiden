local Object = require "mod.class.Object"

function findFurthestFreeGrid(x_start, y_start, sx, sy, radius, block, what)
	local x, y, options = util.findFreeGrid(sx, sy, radius, block, what)
	if not x then return nil end
	table.sort(options, function(a, b)
							 return core.fov.distance(x_start, a[1], y_start, a[2]) > core.fov.distance(x_start, b[1], y_start, b[2])
											end)
	return options[1][1], options[1][2], options
end

newTalent{
	name = "Earthdrum", short_name = "REK_HEKA_MOUNTAIN_EARTHDRUM",
	type = {"spell/mountainshaper", 1}, require = str_req1, points = 5,
	cooldown = 8,
	speed = "movement",
	getNb = function(self, t) return math.floor(self:combatTalentLimit(t, 8, 1.5, 3.6)) end,
	range = 1,
	tactical = { ESCAPE=1, CLOSEIN=1 },
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), simple_dir_request=true} end, --hitball?
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local hit, x, y = self:canProject(tg, self:getTarget(tg))
		if not hit or not x or not y then return nil end

		-- Move
		if self:canMove(x, y) then
			self:move(x, y, true)
		end
		
		if not self:hasEffect(self.EFF_REK_HEKA_DRUMMING) then self:setEffect(self.EFF_REK_HEKA_DRUMMING, t.getNb(self, t), {}) end
		local eff = self:hasEffect(self.EFF_REK_HEKA_DRUMMING)
		eff.turns = eff.turns + 1

		game.logSeen(self, "#CRIMSON#Player at %d %d!", self.x, self.y)
		
		local enemies = {}
		-- find enemy and location
		self:project(
			{type="ball", radius=10, friendlyfire=false, x=self.x, y=self.y}, self.x, self.y,
			function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				game.logSeen(self, "#CRIMSON#Considering actor at %d %d", target.x, target.y)
				enemies[#enemies+1] = target
			end)
		table.sort(enemies, function(a, b) return core.fov.distance(self.x, a.x, self.y, a.y) > core.fov.distance(self.x, b.x, self.y, b.y) end)
		local actor = enemies[1]
		if not actor then return true, {ignore_cd=self:hasEffect(self.EFF_REK_HEKA_DRUMMING)} end

		game.logSeen(self, "#CRIMSON#Actor at %d %d!", actor.x, actor.y)

		local x, y = findFurthestFreeGrid(self.x, self.y, actor.x, actor.y, 1, true, {[Map.ACTOR]=true})
		if not x or not y then return true, {ignore_cd=self:hasEffect(self.EFF_REK_HEKA_DRUMMING)} end

		game.logSeen(self, "#CRIMSON#Wall at %d %d!", x, y)
		
		-- throw off balance and hits
		local dam = 0
		if self:knowTalent(self.T_REK_HEKA_MOUNTAIN_UNCERTAIN) then
			dam = self:spellCrit(self:callTalent(self.T_REK_HEKA_MOUNTAIN_UNCERTAIN, "getDamage"))
		end
		self:project(
			{type="ball", radius=1, friendlyfire=false, x=x, y=y}, x, y,
			function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				target:crossTierEffect(target.EFF_OFFBALANCE, self:combatSpellpower())
				if self:knowTalent(self.T_REK_HEKA_MOUNTAIN_UNCERTAIN) then
					DamageType:get(DamageType.PHYSICAL).projector(self, px, py, DamageType.PHYSICAL, dam)
					if target:canBe("knockback") then
						target:pull(self.x, self.y, 2)
					end
				end
			end)

		local pit_duration = 0
		if self:knowTalent(self.T_REK_HEKA_MOUNTAIN_CRUMBLING) then
			pit_duration = self:callTalent(self.T_REK_HEKA_MOUNTAIN_CRUMBLING, "getDuration")
		end
		
		-- summon pillar
		self:project(
			{type="hit", x=x, y=y}, x, y,
			function(px, py, tg, self)
				local oe = game.level.map(px, py, Map.TERRAIN)
				if oe and not oe:attr("temporary") and not oe.special
					and not game.level.map:checkAllEntities(px, py, "block_move")
				then
					-- it stores the current terrain in "old_feat" and restores it when it expires
					local e = Object.new{
						old_feat = oe,
						name = "stone pillar", image = "terrain/sand/sandwall_5_1.png",
						display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
						desc = "a slowly collapsing wall of stone, raised by the footsteps of the beast",
						type = "wall", subtype = "floor",
						always_remember = true,
						can_pass = {pass_wall=1},
						does_block_move = true,
						show_tooltip = true,
						block_move = true,
						block_sight = true,
						is_pillar = true,
						pit_duration = pit_duration,
						temporary = 5,
						x = px, y = py,
						canAct = false,
						act = function(self)
							self:useEnergy()
							self.temporary = self.temporary - 1
							if self.temporary <= 0 then
								game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
								game.nicer_tiles:updateAround(game.level, self.x, self.y)
								game.level:removeEntity(self)
								game.level.map:scheduleRedisplay()

								if self.pit_duration > 0 and self.summoner and not self.summoner.dead then
									self.summoner:project(
										{type="ball", range=0, radius=1, friendlyfire=false}, self.x, self.y,
										function(px, py)
											local target = game.level.map(px, py, engine.Map.ACTOR)
											if not target then return end
											if target:canBe("pin") then
												target:setEffect(target.EFF_PINNED, t.getDuration(self, t), {src=self.summoner})
												game.level.map:addEffect(self, self.x, self.y, 3, DamageType.REK_HEKA_PIT, {dam=1}, 0, 5, gridsCenter, MapEffect.new{zdepth=6, overlay_particle={zdepth=6, only_one=true, type="circle", args={appear=8, img="pitfall", radius=1, base_rot=0, oversize=1.5}}, color_br=200, color_bg=200, color_bb=200, effect_shader="shader_images/blank_effect.png"}, nil, true)

											end
										end)
								end
							end
						end,
						dig = function(src, x, y, old)
							game.level:removeEntity(old, true)
							game.level.map:scheduleRedisplay()
							return nil, old.old_feat
						end,
						summoner_gain_exp = true,
						summoner = self,
															}
					e.tooltip = mod.class.Grid.tooltip
					game.level:addEntity(e)
					game.level.map(px, py, Map.TERRAIN, e)
				end
      end)
		
		return true, {ignore_cd=self:hasEffect(self.EFF_REK_HEKA_DRUMMING)}
	end,
	info = function(self, t)
		local nb = t.getNb(self, t)
		return ([[Move to an adjacent space, and a pillar of stone will rise up adjacent to the most distant visible foe, knocking off-balance enemies within radius 1.

Pillars of stone block movement for %d turns.

This talent can be used %d times in succession, with a reduced cooldown if only some charges are used.
]]):tformat(5, nb)
	end,
}

newTalent{
	name = "Uncertain Ground", short_name = "REK_HEKA_MOUNTAIN_UNCERTAIN",
	type = {"spell/mountainshaper", 2},	require = str_req2, points = 5,
	mode = "passive",
	range = 1,
	getDamage = function(self, t) return self:combatTalentScale(t, 10, 45) end,
	-- implemented in Earthdrum
	info = function(self, t)
		return ([[When a pillar rises, it does so with great force, dealing %0.1f physical damage and knocking enemies 2 spaces towards you.]]):tformat(damDesc(self, DamageType.MIND, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Crumbling Kingdom", short_name = "REK_HEKA_MOUNTAIN_CRUMBLING",
	type = {"spell/mountainshaper", 3}, require = str_req3, points = 5,
	hands = 10,
	tactical = { DISABLE = 1 },
	cooldown = 10,
	no_energy = true,
	range = 10,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=1, talent=t} end,
	getDuration = function(self, t) return 3 end,
	getAmp = function(self, t) return self:combatTalentLimit(t, 1.5, 1.1, 1.3) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, _ = self:getTarget(tg)
		if not self:canProject(tg, x, y) then return nil end
		local target = game.level.map(hd.x, hd.y, Map.TERRAIN)
		if not target.is_pillar then return nil end

		target.temporay = 0
		target:act()

		return true
	end,
	info = function(self, t)
		return ([[When a pillar expires, it collapses the ground in radius 1 into a pit, pinning enemies in the area for %d turns.  You do %d%% increased damage to targets in the area of a pit.

You can activate this talent to collapse a pillar immediately.]]):tformat(t.getDuration(self, t), t.getAmp(self, t)*100-100)
	end,
}
class:bindHook("DamageProjector:final", function(self, hd)
	local src = hd.src
	local dam = hd.dam
	local target = game.level.map(hd.x, hd.y, Map.ACTOR)

	local deff = game.level.map:hasEffectType(target.x, target.y, DamageType.REK_HEKA_PIT)
	if deff and src.knowTalent and src:knowTalent(src.T_REK_HEKA_MOUNTAIN_CRUMBLING) then
		local state = hd.state
		local type = hd.type
		local reflected = math.min(dam, deff.dam.dam)
		hd.dam = hd.dam * src:callTalent(src.T_REK_HEKA_MOUNTAIN_CRUMBLING, "getAmp")
	end
	return hd
end)

newTalent{
	name = "Unattainable Peak", short_name = "REK_HEKA_MOUNTAIN_PEAK",
	type = {"spell/mountainshaper", 4}, require = str_req4, points = 5,
	mode = "passive",
	getHeal = function(self, t) return self:combatTalentSpellDamage(t, 0, 14) end,
	doHeal = function(self, t, hands)
		-- called by individual effects and talents
		self:attr("allow_on_heal", 1)
		self:heal(self:spellCrit(t.getHeal(self, t)*hands), self)
		self:attr("allow_on_heal", -1)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true ,size_factor=1.0, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false,size_factor=1.0, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0}))
		end
	end,
	info = function(self, t)
		return ([[When your hands reunite with you after ending a talent that drains hands, invests hands, or has a sustained hand cost, you are healed by %d per hand.
Spellpower: increases healing]]):tformat(t.getHeal(self, t))
	end,
}

