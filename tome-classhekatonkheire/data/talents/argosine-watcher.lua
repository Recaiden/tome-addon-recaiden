countEyes = function(self)
	local eyes = 0
	if not game.level then return 0 end
	for _, e in pairs(game.level.entities) do
		if e and e.summoner and e.summoner == self and e.is_wandering_eye then 
			eyes = eyes + 1 
		end
	end
	return eyes
end

newTalent{
	name = "See No Evil", short_name = "REK_HEKA_WATCHER_LASHING",
	type = {"spell/watcher", 1}, require = mag_req1, points = 5,
	points = 5,
	cooldown = 6,
	hands = 20,
	tactical = { ATTACK = {MIND = 1}, DISABLE = 2 },
	range = 10,
	direct_hit = true,
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 250) end,
	getDuration = function(self, t) return 2 + math.ceil(self:combatTalentScale(t, 0.3, 2.3)) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end
		
		-- Project our damage
		self:project(tg, x, y, DamageType.MIND, self:spellCrit(t.getDamage(self, t)))
		
		game.level.map:particleEmitter(x, y, 1, "temporal_thrust")
		game:playSoundNear(self, "talents/arcane")
		
		-- If they're dead don't remove them from time
		if target.dead or target.player then return true end
		
		-- Check hit
		local hit = self:checkHit(self:combatSpellpower(), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
		if not hit then game.logSeen(target, "%s resists!", target:getName():capitalize()) return true end
		
		-- Apply spellshock and destabilization
		target:crossTierEffect(target.EFF_SPELLSHOCKED, self:combatSpellpower())
		target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower()*0.3})
		
		-- Placeholder for the actor
		local oe = game.level.map(x, y, Map.TERRAIN+1)
		if (oe and oe:attr("temporary")) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then game.logPlayer(self, "Something has prevented you from looking away.") return true end
		local e = mod.class.Object.new{
			old_feat = oe, type = "dimensional", subtype = "instability",
			name = _t"dimensional instability",
			display = '&', color=colors.LIGHT_BLUE,
			temporary = t.getDuration(self, t),
			canAct = false,
			target = target,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				-- return the rifted actor
				if self.temporary <= 0 then
					-- remove ourselves
					if self.old_feat then game.level.map(self.target.x, self.target.y, engine.Map.TERRAIN+1, self.old_feat)
					else game.level.map:remove(self.target.x, self.target.y, engine.Map.TERRAIN+1) end
					game.nicer_tiles:updateAround(game.level, self.target.x, self.target.y)
					game.level:removeEntity(self)
					game.level.map:removeParticleEmitter(self.particles)
					
					-- return the actor and reset their values
					local mx, my = util.findFreeGrid(self.target.x, self.target.y, 20, true, {[engine.Map.ACTOR]=true})
					local old_levelup = self.target.forceLevelup
					local old_check = self.target.check
					self.target.forceLevelup = function() end
					self.target.check = function() end
					game.zone:addEntity(game.level, self.target, "actor", mx, my)
					self.target.forceLevelup = old_levelup
					self.target.check = old_check
				end
			end,
			summoner_gain_exp = true, summoner = self,
		}
		
		-- Remove the target
		game.logSeen(target, "%s has disappeared!", target:getName():capitalize())
		game.level:removeEntity(target, true)
		
		-- add the time skip object to the map
		local particle = Particles.new("wormhole", 1, {image="shockbolt/terrain/temporal_instability_white", speed=1})
		particle.zdepth = 6
		e.particles = game.level.map:addParticleEmitter(particle, x, y)
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN+1, e)
		game.level.map:updateMap(x, y)

		-- invest cost
		game:onTickEnd(function() 
				self:setEffect(self.EFF_REK_HEKA_INVESTED, t:_getDuration(self),
											 {investitures={{power=util.getval(t.hands, self, t)}}, src=self})
		end)
		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[Turn your attention away from a target and let them fall into the other place.  This inflicts %0.1f mind damage and freezes the target in time for %d turns.
The damage will scale with your Spellpower.
This talent invests hands; your maximum hands will be reduced by its cost until it expires.]]):tformat(damDesc(self, DamageType.MIND, damage), duration)
	end,
}

newTalent{
	name = "Oversight", short_name = "REK_HEKA_WATCHER_OVERWATCH",
	type = {"spell/watcher", 2},	require = mag_req2, points = 5,
	mode = "passive",
	getOverwatch = function(self, t) return self:combatTalentScale(t, 1, 5) end,
	--used in an effect applied in the eye's stare down talent via the STARE damage type
	info = function(self, t)
		return ([[Rest easy knowing that someone is watching your back, even if that someone is you.  When you are in the area of an Evil Eye, your health regeneration is increased by %d and your saves by %d.]]):tformat(t.getOverwatch(self, t), t.getOverwatch(self, t)*8)
	end,
}

newTalent{
	name = "Inescapable Gaze", short_name = "REK_HEKA_WATCHER_INESCAPABLE",
	type = {"spell/watcher", 3}, require = mag_req3, points = 5,
	mode = "passive",
	getMultiplier = function(self, t) return math.max(1, self:combatTalentLimit(t, 5, 1.5, 2.25)) end,
	-- handled in the STARE damage type
	info = function(self, t)
		return ([[If an enemy is affected by multiple Evil Eyes in one turn, the damage will be increased by %d%% and the slow by %d%%.]]):tformat(t.getMultiplier(self, t)*200-100, t.getMultiplier(self, t)*100)
	end,
}


newTalent{
	name = "Eye Hatchery", short_name = "REK_HEKA_WATCHER_HATCHERY",
	type = {"spell/watcher", 4}, require = eye_req_slow4, points = 5,
	mode = "passive",
	getBonusEyes = function(self, t) return math.ceil(self:combatTalentLimit(t, 4, 0.5, 2.95)) end,
	getInherit = function(self, t) return self:combatTalentScale(t, 20, 60) end,
	info = function(self, t)
		return ([[Your maximum number of wandering eyes is increased by %d.
In addition, your eyes inherit %d%% of your spellpower, damage increases (applied to all elements), and damage penetration (applied to all elements).]]):tformat(t.getBonusEyes(self, t), t.getInherit(self, t))
	end,
}

newTalent{
	name = "Panopticon", short_name = "REK_HEKA_WATCHER_PANOPTICON",
	type = {"spell/watcher", 4}, require = mag_req4, points = 5,
	hands = 40,
	tactical = { DISABLE = 5 },
	cooldown = 50,
	no_npc_use=true,
	range = 5,
	getSightBonus = function(self, t) return math.floor(self:combatTalentLimit(t, 4, 1, 3)) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "sight", t.getSightBonus(self, t))
	end,
	getDuration = function(self, t) return self:combatTalentScale(t, 2, 4.5)	end,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(target.x, target.y, x, y) > 5 then return nil end
		if not target:hasProc("heka_panopticon_ready") then return nil end
		target:setEffect(target.EFF_REK_HEKA_PANOPTICON, t.getDuration(self, t), {})
		game.level.map:particleEmitter(self.x, self.y, 1, "circle", {oversize=1.7, a=170, limit_life=12, shader=true, appear=12, speed=0, base_rot=180, img="oculatus", radius=0})
		return true
	end,
	info = function(self, t)
		return ([[Paralyze a target wth the weight of your gaze.  A target who has been seen by at least two Evil Eyes is rendered unable to act for %d turns (#SLATE#No save or immunity#LAST#).

Passively increases the sight range of your eyes by %d.]]):tformat(t.getDuration(self, t), t.getSightBonus(self, t))
	end,
}
