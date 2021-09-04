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
	getNb = function(self, t) return 2+math.floor(self:combatTalentLimit(t, 7, 1.5, 4)) end,
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

		local enemies = {}
		-- find enemy and location
		self:project(
			{type="ball", radius=10, friendlyfire=false, x=self.x, y=self.y}, self.x, self.y,
			function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				enemies[#enemies+1] = target
			end)
		--table.sort(enemies, function(a, b) return core.fov.distance(self.x, a.x, self.y, a.y) > core.fov.distance(self.x, b.x, self.y, b.y) end)
		local actor = rng.table(enemies)
		if not actor then return true, {ignore_cd=self:hasEffect(self.EFF_REK_HEKA_DRUMMING)} end


		local x, y = findFurthestFreeGrid(self.x, self.y, actor.x, actor.y, 1, true, {[Map.ACTOR]=true})
		if not x or not y then return true, {ignore_cd=self:hasEffect(self.EFF_REK_HEKA_DRUMMING)} end
		
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
						name = "stone pillar", image = oe.image,--image = "terrain/shaped_pillar.png",
						display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
						desc = _t"a slowly sinking wall of stone, raised by the footsteps of the beast",
						type = "wall", --subtype = "floor",
						always_remember = true,
						can_pass = {pass_wall=1},
						does_block_move = true,
						show_tooltip = true,
						block_move = true,
						block_sight = false,
						is_pillar = true,
						pit_duration = pit_duration,
						temporary = 5,
						x = px, y = py,
						canAct = false,
						act = function(self)
							self:useEnergy()
							self.temporary = self.temporary - 1
							if self.temporary <= 0 then
								local geff = game.level.map:hasEffectType(self.x, self.y, engine.DamageType.REK_HEKA_PILLAR)
								if geff then game.level.map:removeEffect(geff) end
								game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
								game.nicer_tiles:updateAround(game.level, self.x, self.y)
								game.level:removeEntity(self)
								game.level.map:scheduleRedisplay()

								if self.pit_duration > 0 and self.summoner and not self.summoner.dead then
									local grids = self.summoner:project(
										{type="ball", range=0, radius=2, start_x=self.x, start_y=self.y, friendlyfire=false}, self.x, self.y,
										function(px, py)
											local target = game.level.map(px, py, engine.Map.ACTOR)
											if not target then return end
											if target:canBe("pin") then
												target:setEffect(target.EFF_PINNED, self.pit_duration, {src=self.summoner})
												

											end
									end)
									local MapEffect = require "engine.MapEffect"
									game.level.map:addEffect(self, self.x, self.y, self.pit_duration, engine.DamageType.REK_HEKA_PIT, {dam=1}, 1, 5, nil, MapEffect.new{zdepth=5, overlay_particle={zdepth=5, only_one=true, type="circle", args={appear=8, img="pitfall", radius=2, base_rot=0, oversize=1.5, a=187}}, alpha=0, effect_shader="shader_images/blank_effect.png"}, nil, true)									
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

					-- draw fake pillar
					game.level.map:addEffect(self, px, py, 5, engine.DamageType.REK_HEKA_PILLAR, {dam=1}, 0, 5, nil, MapEffect.new{zdepth=5, overlay_particle={zdepth=5, only_one=true, type="circle", args={appear=8, img="shaped_pillar", radius=0, base_rot=1, speed=0, oversize=1.0, a=250}}, alpha=0, effect_shader="shader_images/blank_effect.png"}, nil, true)
				end
      end)
		
		return true, {ignore_cd=self:hasEffect(self.EFF_REK_HEKA_DRUMMING)}
	end,
	info = function(self, t)
		local nb = t.getNb(self, t)
		return ([[Move to an adjacent space, and a pillar of stone will rise up behind to a visible foe, knocking off-balance enemies within radius 1.

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
		return ([[When a pillar rises, it does so with great force, dealing %0.1f physical damage and knocking enemies 2 spaces towards you.]]):tformat(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
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
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=1, nolock=true, pass_terrain=true, nowarning=true, talent=t} end,
	getDuration = function(self, t) return 3 end,
	getAmp = function(self, t) return self:combatTalentLimit(t, 1.5, 1.1, 1.3) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, _ = self:getTarget(tg)
		if not self:canProject(tg, x, y) then return nil end
		local target = game.level.map(x, y, Map.TERRAIN)
		if not target.is_pillar then return nil end

		target.temporary = 0
		target:act()

		return true
	end,
	info = function(self, t)
		return ([[When a pillar expires, it collapses the ground in radius 2 into a pit, pinning enemies in the area for %d turns.  You do %d%% increased damage to targets in the area of a pit.

You can activate this talent to collapse a pillar immediately.]]):tformat(t.getDuration(self, t), t.getAmp(self, t)*100-100)
	end,
}
class:bindHook("DamageProjector:final", function(self, hd)
	local src = hd.src
	local dam = hd.dam
	local target = game.level.map(hd.x, hd.y, Map.ACTOR)
	if not target then return hd end

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
	hands = 20,
	cooldown = 20,
	on_pre_use = function(self, t, silent)
		local count = 0
		if not game or not game.level then return false end
		self:project(
			{type="ball", range=0, radius=10, no_restrict=true},
			self.x, self.y,
			function(px, py)
				local target = game.level.map(px, py, Map.TERRAIN)
				if not target.is_pillar then return nil end
				count = count + 1
			end)
		if count == 0 and not silent then game.logPlayer(self, "You have no pillars") end
		return count > 0
	end,
	getDuration = function(self, t) return 5 end,
	getDamage = function(self, t) return self:combatTalentPhysicalDamage(t, 10, 320) end,
	action = function(self, t)
		local dam = self:spellCrit(t.getDamage(self, t))
		
		local hit = {}
		self:project(
			{type="ball", range=0, radius=10, no_restrict=true},
			self.x, self.y,
			function(lx, ly)
				local target = game.level.map(lx, ly, Map.TERRAIN)
				if not target.is_pillar then return end
				self:project(
					{type="beam", range=10, friendlyfire=false}, lx, ly,
					function(px, py)
						local target = game.level.map(px, py, engine.Map.ACTOR)
						if not target then return end
						if hit[target.uid] then return end
						hit[target.uid] = true
						DamageType:get(DamageType.PHYSICAL).projector(self, px, py, DamageType.PHYSICAL, dam)
						if target:canBe("stun") then
							target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=self:combatPhysicalpower(), apply_save="combatMentalResist", src=self})
						end
					end)
			end)
		return true
	end,
	info = function(self, t)
		return ([[Warp space to crush all enemies between you and any pillars, dealing %0.1f physical damage and stunning (#SLATE#physical vs mind#LAST#) them for %d turns.
Spellpower: increases damage.]]):tformat(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)), t.getDuration(self, t))
	end,
}
