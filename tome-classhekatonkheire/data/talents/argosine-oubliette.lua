newTalent{
	name = "Earthdrum", short_name = "REK_HEKA_TENTACLE_EARTHDRUM",
	type = {"spell/oubliette", 1}, require = str_req1, points = 5,
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
		if self:knowTalent(self.T_REK_HEKA_TENTACLE_UNCERTAIN) then
			dam = self:spellCrit(self:callTalent(self.T_REK_HEKA_TENTACLE_UNCERTAIN, "getDamage"))
		end
		self:project(
			{type="ball", radius=1, friendlyfire=false, x=x, y=y}, x, y,
			function(px, py)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if not target then return end
				target:crossTierEffect(target.EFF_OFFBALANCE, self:combatSpellpower())
				if self:knowTalent(self.T_REK_HEKA_TENTACLE_UNCERTAIN) then
					DamageType:get(DamageType.PHYSICAL).projector(self, px, py, DamageType.PHYSICAL, dam)
					if target:canBe("knockback") then
						target:pull(self.x, self.y, 2)
					end
				end
			end)

		local pit_duration = 0
		if self:knowTalent(self.T_REK_HEKA_TENTACLE_CRUMBLING) then
			pit_duration = self:callTalent(self.T_REK_HEKA_TENTACLE_CRUMBLING, "getDuration")
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
	name = "Uncertain Ground", short_name = "REK_HEKA_TENTACLE_UNCERTAIN",
	type = {"spell/oubliette", 2},	require = str_req2, points = 5,
	mode = "passive",
	range = 1,
	getDamage = function(self, t) return self:combatTalentScale(t, 10, 45) end,
	-- implemented in Earthdrum
	info = function(self, t)
		return ([[When a pillar rises, it does so with great force, dealing %0.1f physical damage and knocking enemies 2 spaces towards you.]]):tformat(damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)))
	end,
}

newTalent{
	name = "Crumbling Kingdom", short_name = "REK_HEKA_TENTACLE_CRUMBLING",
	type = {"spell/oubliette", 3}, require = str_req3, points = 5,
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
		return ([[Up to %d detrimental effects will be copied to random nearby enemies, with their durations increased by %d%% (rounded up). Each enemy affected also deals %d%% less damage for as long as the longest effect copied to them. You still suffer from the effects.]]):tformat(t.getDuration(self, t), t.getAmp(self, t)*100-100)
	end,
}

newTalent{
	name = "Void of Meaning", short_name = "REK_HEKA_TENTACLE_EXECUTE",
	type = {"spell/oubliette", 4}, require = str_req4, points = 5,
	mode = "passive"
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 50) end,
	getPowerBonus = function(self, t) return self:combatTalentScale(t, 5, 30) end,
	kill = function(self, t, target)
		if target.turn_procs and target.turn_procs.rek_heka_tentacle then return end
		if target.life > target.max_life * 0.1 then return end
		if not target:checkHit(src:combatSpellpower(1, t.getPowerBonus(self, t)), target:combatMentalResist()) then return end
		target:setProc("rek_heka_tentacle", 3)
		if target:canBe("instakill") then
			target:die()
		else
			DamageType:get(DamageType.MIND).projector(self, target.x, target.y, DamageType.MIND, t.getDamage(self, t))
			target:crossTierEffect(target.EFF_BRAINLOCKED, self:combatSpellpower(1, t.getPowerBonus(self, t)))
		end
	end,
	callbackOnDealDamage = function(self, t, val, target, dead, death_note)
		if val <= 0 then return end
		if self.summoner and self:reactionToward(target) < 0 then
			if rng.percent(self.summoner:callTalent("T_TERROR_FRENZY", "getChance")) then
				self.summoner:callTalent("T_TERROR_FRENZY", "doReset")
			end
		end
	end,
	info = function(self, t)
		return ([[When you or your summons reduce a creature to less than 10%% life, it may die instantly (#SLATE#mental save vs spellpower + %d#LAST#).  Creatures immune to instant death instead take %0.1f mind damage and may be brainlocked.  This can only affect a given creature once every 3 turns.
Spellpower: increases damage.]]):tformat(t.getPowerBonus(self, t), damDesc(self, DamageType.MIND, t.getDamage(self, t)))
	end,
}
