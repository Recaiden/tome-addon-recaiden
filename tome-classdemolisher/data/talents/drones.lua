local Object = require "mod.class.Object"

-- Actually launces a projectile that makes a melee attack with your ammo.
newTalent{
	name = "Gunner Drone", short_name = "REK_DEML_DRONE_GUNNER",
	type = {"steamtech/drones", 1},
	require = steam_req_mastery,
	points = 5,
	mode = "sustained",
	drain_steam = 3,
	cooldown = 10,
	tactical = { ATTACKAREA = { weapon = 2 }, },
	getPower = function(self, t) return 30 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 1.5 end,
	getDamage = function(self, t) return 0.25 + self:combatTalentWeaponDamage(t, 0.3, 0.7) end,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t,
						display=self:archeryDefaultProjectileVisual(nil, self:hasAmmo()),
						friendlyblock=false, friendlyfire=false}
	end,
	range = function(self, t) return math.min(10, self:combatTalentScale(t, 6, 10)) end,
	getReload = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3)) end,
	autoshoot = function(self, range, x, y)
		local tg = {
			speed = 6, type="bolt", range=range, selffire=false, friendlyfire=false, friendlyblock=false,
			display=self:archeryDefaultProjectileVisual(nil, self:hasAmmo())
		}
		local proj = self:projectile(
			tg, x, y,
			function(px, py, tg, self)
				local target = game.level.map(px, py, engine.Map.ACTOR)
				if target and target ~= self then
					if not self:getInven("QUIVER") then return end
					local ammoWeapon = table.clone(self:getInven("QUIVER")[1])
					if not ammoWeapon or not ammoWeapon.combat then return end
					local combat = table.clone(ammoWeapon.combat)
					-- copy ranged_project to melee_project
					combat.melee_project = {}
					for k, v in pairs(combat) do
						if (k == "ranged_project") then
							combat["melee_project"] = v
						end
					end
					local multiplier = self:callTalent(self.T_REK_DEML_DRONE_GUNNER, "getPercentInc")
					local dam = self:callTalent(self.T_REK_DEML_DRONE_GUNNER, "getDamage")
					local power = self:callTalent(self.T_REK_DEML_DRONE_GUNNER, "getPower")

					combat.dam = combat.dam * (1 + multiplier)
					local tempPow = self:addTemporaryValue("combat_dam", power)
					local hit = self:attackTargetWith(target, combat, nil, dam)
					self:removeTemporaryValue("combat_dam", tempPow)
					
					if combat.sound and hit then game:playSoundNear(self, combat.sound)
					elseif combat.sound_miss then game:playSoundNear(self, combat.sound_miss) end
				end
			end)
		return proj
	end,
	activateGunner = function(self, t)
		local ammo = self:hasAmmo()
		if not ammo or not ammo.combat then
			return
		end
		if ammo.combat.shots_left == 0 then
			local reloading = self:addTemporaryValue('ammo_mastery_reload', t.getReload(self, t))
			self:reload()
			self:removeTemporaryValue("ammo_mastery_reload", reloading)
		else
			local tgts = {}
			local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
			for x, yy in pairs(grids) do
				for y, _ in pairs(grids[x]) do
					local a = game.level.map(x, y, Map.ACTOR)
					if a and self:reactionToward(a) < 0 and self:canSee(a) then
						tgts[#tgts+1] = a
					end
				end
			end
			
			-- Aim at a single target and shoot them
			local tg = self:getTalentTarget(t)
			if #tgts <= 0 then
				return
			end
			local a, id = rng.table(tgts)
			if not a.x or not a.y then
				return nil
			end
			local _ _, x, y = self:canProject(tg, a.x, a.y)
			game:playSoundNear(self, {"talents/single_steamgun", vol=0.8})
			local proj = t.autoshoot(self, tg.range, x, y)
			proj.name = _t"gunner drone"
			if not ammo.infinite then
				if ammo.combat.shots_left <= 0 then return nil end
				ammo.combat.shots_left = ammo.combat.shots_left - 1
			end
		end
		return true
	end,
	callbackOnActBase = function(self, t)
		if self:getSteam() < 0.1 then
			self:forceUseTalent(t.id, {ignore_energy=true})
			return
		end
		t.activateGunner(self, t)
		local rev = self:hasEffect(self.EFF_REK_DEML_REVVED_UP)
		if rev and rng.percent(rev.power*100) then t.activateGunner(self, t) end
	end,
	activate = function(self, t)
		local ret = {}		

		if core.shader.active() then
			-- custom size-scaling shader
			if self.deml_drone_style and self.deml_drone_style == "beetle" then
				self:talentParticles(ret, {type="shader_shield", args={toback=true,  size_factor=1.7, img="rotating_gunbeetle_drone_centered"}, shader={type="orbitting_drone", noup=2.0, cylinderRadius=0.50, cylinderVerticalPos=-0.06, cylinderRotationSpeed=2.0, appearTime=0.2}})
				self:talentParticles(ret, {type="shader_shield", args={toback=false, size_factor=1.7, img="rotating_gunbeetle_drone_centered"}, shader={type="orbitting_drone", noup=1.0, cylinderRadius=0.50, cylinderVerticalPos=-0.06, cylinderRotationSpeed=2.0, appearTime=0.2}})
			else
				self:talentParticles(ret, {type="shader_shield", args={toback=true,  size_factor=1.7, img="rotating_gunner_drone_centered"}, shader={type="orbitting_drone", noup=2.0, cylinderRadius=0.50, cylinderVerticalPos=-0.06, cylinderRotationSpeed=2.0, appearTime=0.2}})
				self:talentParticles(ret, {type="shader_shield", args={toback=false, size_factor=1.7, img="rotating_gunner_drone_centered"}, shader={type="orbitting_drone", noup=1.0, cylinderRadius=0.50, cylinderVerticalPos=-0.06, cylinderRotationSpeed=2.0, appearTime=0.2}})
			end
		end

		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Deploy a tiny autonomous machine to hover around you and shoot at your enemies.  Each round, it uses your ammo to attack an enemy in range %d, dealing %d%% damage.  These attacks use your accuracy, will have %d increased Physical Power and %d%% more damage, and apply on-hit effects as if they were melee attacks.
If your ammo is depleted, it instead reloads (with %d extra ammunition reloaded).
The shots will pass harmlessly through allies.

The drone deactivates if you run out of steam.]]):tformat(self:getTalentRange(t), t.getDamage(self,t)*100, t.getPower(self,t), t.getPercentInc(self, t)*100, t.getReload(self, t))
	end,
}

newTalent{
	name = "Artificial Storm", short_name = "REK_DEML_DRONE_STORM",
	type = {"steamtech/other",1},
	points = 5,
	cooldown = 4,
	tactical = { ATTACKAREA = { LIGHTNING = 2 }, DISABLE = { blind = 1 } },
	range = 0,
	radius = 3,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	getDamage = function(self, t) return self:combatTalentSteamDamage(t, 30, 120) + self.level end,
	getDuration = function(self, t) return 4 end,
	action = function(self, t)
		local friendlyfire = true
		-- Add a lasting map effect
		game.level.map:addEffect(self,
														 self.x, self.y, t.getDuration(self, t),
														 DamageType.REK_DEML_STORM, self.summoner_damage or t.getDamage(self, t),
														 3,
														 5, nil,
														 {type="icestorm", only_one=true},
														 function(e)
															 e.x = e.src.x
															 e.y = e.src.y
															 return true
														 end,
														 false, friendlyfire
														)
		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[A furious electrical storm rages around the user doing %0.2f lightning damage in a radius of 3 each turn for %d turns with a 25%% chance to blind.
The storm cannot critically hit.
Steampower: increases damage]]):tformat(damDesc(self, DamageType.LIGHTNING, damage), duration)
	end,
}

newTalent{
	name = "Hurricane Drone", short_name = "REK_DEML_DRONE_HURRICANE",
	type = {"steamtech/drones", 2},
	require = steam_req2,
	points = 5,
	steam = 20,
	cooldown = 15,
	range = 7,
	tactical = { ATTACKAREA = {LIGHTNING = 2} },
	requires_target = true,
	getDam = function(self, t) return self:combatTalentSteamDamage(t, 10, 40) + self.level end,
	getResist = function(self, t) return self:combatTalentSteamDamage(t, 20, 50) end,
	getArmor = function(self, t) return self:combatTalentSteamDamage(t, 5, 45) end,
	getHP = function(self, t) return self:combatTalentSteamDamage(t, 10, 1000) end,
	target = function(self, t) return {type="ball", nowarning=true, radius=3, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)--{type="bolt", nowarning=true, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end
		
		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end
		
		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "construct", subtype = "drone",
			display = "*", color=colors.GREEN,
			name = "hurricane drone", faction = self.faction, image = (self.deml_drone_style and self.deml_drone_style == "beetle") and "npc/hurricane_beetle_drone.png" or "npc/hurricane_drone.png",
			desc = _t[[A strange hovering device of whirling blades. Your hair stands on end when you approach.]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented", ai_state = { talent_in=1, },
			level_range = {1, 1}, exp_worth = 0,
			
			max_life = self:steamCrit(t.getHP(self, t)),
			life_rating = 0,
			never_move = 1,

			summoner_damage = t.getDam(self, t),
			inc_damage = table.clone(self.inc_damage),
			resists_pen = table.clone(self.resists_pen),

			combat_armor_hardiness = 50,
			combat_armor = t.getArmor(self, t),
			resists = {all = t.getResist(self, t)},

			negative_status_effect_immune = 1,
			cant_be_moved = 1,
			bomb_drone = 1,

			on_act = function(self)
				local tg = {type="ball", range=0, friendlyfire=false, radius=3}	
				self:project(tg, self.x, self.y, engine.DamageType.REK_DEML_STORM, self.summoner_damage )
				game.level.map:particleEmitter(self.x, self.y, 1, "shout", {size=4, distorion_factor=0.3, radius=3, life=30, nb_circles=8, rm=0.1, rM=0.3, gm=0, gM=0, bm=0.8, bM=0.8, am=0.6, aM=0.8})
				game:playSoundNear(self, {"talents/lightning", vol=0.4})
				self.energy.value = 0
			end,

			summoner = self, summoner_gain_exp=true,
			summon_time = 10,
			--embed_particles = {{name="bolt_lightning"}},
		}

		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		game.zone:addEntity(game.level, m, "actor", x, y)
		return true
	end,
	info = function(self, t)
		return ([[Deploy a tiny autonomous machine to a nearby location, where it creates a storm of whirling metal and electricity which does %d lightning damage in radius 3 with a 25%% chance to blind.
The drone has %d life (increased by steam critical), %d armor, and %d%% resistance to all damage. It lasts 10 turns.
It inherits your increased damage and penetration.
Steampower: improves	damage, life, resists, and armor]]):
		tformat(damDesc(self, DamageType.LIGHTNING, t.getDam(self, t)), t.getHP(self, t), t.getArmor(self, t), t.getResist(self, t))
	end,
}

newTalent{
	name = "Guardian Drone", short_name = "REK_DEML_DRONE_GUARD",
	type = {"steamtech/drones", 3},
	require = steam_req3,
	points = 5,
	mode = "sustained",
	drain_steam = 3,
	cooldown = 10,
	tactical = { DEFEND = 3 },
	getShrug = function(self, t) return self:combatTalentSteamDamage(t, 1.5, 30) end,
	getMaxShrug = function(self, t) return t.getShrug(self, t) * self:combatTalentStatDamage(t, "dex", 4, 8) end,
	activate = function(self, t)
		local ret = {
			value = t.getShrug(self, t) * 5,
		}
		if core.shader.active() then
			if self.deml_drone_style and self.deml_drone_style == "beetle" then
				self:talentParticles(ret, {type="shader_shield", args={toback=true,  size_factor=1.2, img="rotating_beetle_drone_centered"}, shader={type="orbitting_drone", noup=2.0, cylinderRadius=0.42, cylinderHeight = 0.3, cylinderVerticalPos=-0.17, cylinderRotationSpeed=1.5, appearTime=0.2}})
				self:talentParticles(ret, {type="shader_shield", args={toback=false, size_factor=1.2, img="rotating_beetle_drone_centered"}, shader={type="orbitting_drone", noup=1.0, cylinderRadius=0.42, cylinderHeight = 0.3, cylinderVerticalPos=-0.17, cylinderRotationSpeed=1.5, appearTime=0.2}})
			else
				self:talentParticles(ret, {type="shader_shield", args={toback=true,  size_factor=1.2, img="rotating_guardian_drone_centered"}, shader={type="orbitting_drone", noup=2.0, cylinderRadius=0.42, cylinderHeight = 0.3, cylinderVerticalPos=-0.17, cylinderRotationSpeed=1.5, appearTime=0.2}})
				self:talentParticles(ret, {type="shader_shield", args={toback=false, size_factor=1.2, img="rotating_guardian_drone_centered"}, shader={type="orbitting_drone", noup=1.0, cylinderRadius=0.42, cylinderHeight = 0.3, cylinderVerticalPos=-0.17, cylinderRotationSpeed=1.5, appearTime=0.2}})
			end
		end
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	callbackOnActBase = function(self, t)
		if self:getSteam() < 0.1 then
			self:forceUseTalent(t.id, {ignore_energy=true})
			return
		end
		local p = self:isTalentActive(t.id)
		p.value = t.getMaxShrug(self, t)
	end,
	callbackPriorities={callbackOnTakeDamage = 2},
	callbackOnTakeDamage = function(self, t, src, x, y, type, dam, state)
		local fend  = t.getShrug(self, t)
		local rev = self:hasEffect(self.EFF_REK_DEML_REVVED_UP)
		if rev then fend = fend * (1+rev.power) end
		local p = self.sustain_talents[t.id]
		if not p or p.value == 0 then return {dam=dam} end

		local block = 0
		if dam < fend then
			block = dam
		elseif dam > fend * 3 then
			block = fend * 2
		else
			block = fend + (dam - fend)/2
		end
		block = math.min(p.value, block)
		dam = dam - block
		p.value = p.value - block

		game:delayedLogDamage(src or self, self, 0, ("%s(%d guarded)#LAST#"):tformat(DamageType:get(type).text_color or "#aaaaaa#", block), false)
		
		return {dam=dam}
	end,
	info = function(self, t)
		return ([[Deploy a tiny autonomous machine to hover around you and deflect incoming blows.  You reduce incoming damage by %d to %d (more for stronger hits), but the drone can only deflect %d total damage each round.
Steampower: increases damage deflected
Dexterity: increases maximum deflection per round

The drone deactivates if you run out of steam.]]):tformat(t.getShrug(self, t), t.getShrug(self, t)*2, t.getMaxShrug(self, t))
	end,
}

newTalent{
	name = "Shroud Drone", short_name = "REK_DEML_DRONE_SMOKE",
	type = {"steamtech/drones", 4},
	require = steam_req4,
	points = 5,
	cooldown = 15,
	steam = 20,
	tactical = { DISABLE = 2 },
	range = 7,
	tactical = { ATTACKAREA = {LIGHTNING = 2} },
	requires_target = true,
	getSightLoss = function(self, t) return math.floor(self:combatTalentScale(t, 2, 7, "log", 0, 4)) end,
	getResist = function(self, t) return self:combatTalentSteamDamage(t, 20, 50) end,
	getArmor = function(self, t) return self:combatTalentSteamDamage(t, 5, 45) end,
	getHP = function(self, t) return self:combatTalentSteamDamage(t, 10, 1000) end,
	target = function(self, t) return {type="ball", nowarning=true, radius=3, range=self:getTalentRange(t), nolock=true, simple_dir_request=true, talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, _, _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if target == self then target = nil end
		
		-- Find space
		local x, y = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end
		
		local NPC = require "mod.class.NPC"
		local m = NPC.new{
			type = "construct", subtype = "drone",
			display = "*", color=colors.GREEN,
			name = "shroud drone", faction = self.faction, image = (self.deml_drone_style and self.deml_drone_style == "beetle") and "npc/smoke_beetle_drone.png" or "npc/smoke_drone.png",
			desc = _t[[A strange hovering device of hissing smoke, nearly impossible to see.]],
			autolevel = "none",
			ai = "summoned", ai_real = "dumb_talented", ai_state = { talent_in=1, },
			level_range = {1, 1}, exp_worth = 0,
			
			max_life = self:steamCrit(t.getHP(self, t)),
			life_rating = 0,
			never_move = 1,

			summoner_damage = t.getSightLoss(self, t),
			inc_damage = table.clone(self.inc_damage),
			resists_pen = table.clone(self.resists_pen),

			combat_armor_hardiness = 50,
			combat_armor = t.getArmor(self, t),
			resists = {all = t.getResist(self, t)},

			negative_status_effect_immune = 1,
			cant_be_moved = 1,
			bomb_drone = 1,

			on_act = function(self)
				local tg = {type="ball", range=0, friendlyfire=false, radius=3}	
				self:project(tg, self.x, self.y, DamageType.STEAM_SHADOW_SMOKE, self.summoner_damage )

				game.level.map:addEffect(
					self,
					self.x, self.y, 1,
					DamageType.COSMETIC, {},
					3,
					5, nil,
					{
						type="vapour_spin",
						args={
							radius=1, smoke="particles_images/smoke_dark", density=2,
							sub_particle="vapour_spin",
							sub_particle_args={
								radius=1, smoke="particles_images/smoke_heavy_bright", density=2
							}
						}
					},
					nil, false, false)
				game:playSoundNear(self, {"talents/cloud", vol=0.3})
				self.energy.value = 0
			end,

			summoner = self, summoner_gain_exp=true,
			summon_time = 10,
			embed_particles = {{name="shadow"}},
		}

		m:resolve() m:resolve(nil, true)
		m:forceLevelup(self.level)
		game.zone:addEntity(game.level, m, "actor", x, y)
		return true
	end,
	info = function(self, t)
		return ([[Deploy a tiny autonomous machine to a nearby location, where it creates a cloud of obscuring smoke in radius 3 which reduces sight range of those who enter by %d.
The drone has %d life (increased by steam critical), %d armor, and %d%% resistance to all damage. It lasts 10 turns.
It inherits your increased damage and penetration.
Steampower: improves	damage, life, resists, and armor]]):
		tformat(t.getSightLoss(self, t), t.getHP(self, t), t.getArmor(self, t), t.getResist(self, t))
	end,
}

newTalent{
	name = "Medical Drone", short_name = "REK_DEML_DRONE_MEDIC",
	type = {"steamtech/other", 4},
	require = steam_req4,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return self:combatTalentLimit(t, 6, 15, 8) end,
	steam = 15,
	tactical = {
		DEFEND = 3,
		CURE = function(self, t, target)
			local nb = 0
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if what[e.type] and e.status == "detrimental" then
					nb = nb + 1
				end
			end
			return nb
		end
	},
	getDuration = function(self, t) return self:combatTalentScale(t, 2, 4) end,
	getNb = function(self, t) return self:combatTalentScale(t, 1, 3) end,
	getSaves = function(self, t) return self:combatTalentScale(t, 20, 40, 1.0) end,
	action = function(self, t)
		local what = {physical=true, mental=true, magical=true}
		
		local target = self
		local effs = {}
		local force = {}
		local known = false
		
		-- Go through all temporary effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if what[e.type] and e.status == "detrimental" and e.subtype["cross tier"] then
				force[#force+1] = {"effect", eff_id}
			elseif what[e.type] and e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end
		
		-- Cross tier effects are always removed
		for i = 1, #force do
			local eff = force[i]
			if eff[1] == "effect" then
				target:removeEffect(eff[2])
				known = true
			end
		end
		
		for i = 1, t.getNb(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)
			
			if eff[1] == "effect" then
				target:removeEffect(eff[2])
				known = true
			end
		end
		if known then
			game.logSeen(self, "%s is cured!", self.name:capitalize())
		end
		self:setEffect(self.EFF_REK_DEML_SAVE_BOOST, t.getDuration(self, t), {power=t.getSaves(self, t), src=self})
		return true
	end,
	info = function(self, t)
		return ([[Activate a tiny machine to apply appropriate medical care to you, removing up to %d physical, mental or magical detrimental effects.  Then, for the next %d turns, your saves are increased by %d.]]):tformat(t.getNb(self, t), t.getDuration(self, t), t.getSaves(self, t))
	end,
}
