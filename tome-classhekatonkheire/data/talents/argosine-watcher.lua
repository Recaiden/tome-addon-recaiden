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
	name = "Eye Stock", short_name = "REK_HEKA_WATCHER_RESPAWN",
	type = {"spell/watcher", 2},	require = mag_req2, points = 5,
	cooldown = 5,
	hands = 35,
	getTurns = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5)) end,
	getMaxTurns = function(self, t) return math.floor(self:combatTalentLimit(t, 11, 3, 9.8)) end,
	callbackOnTalentPost = function(self, t, ab, ret, silent)
		if not self.in_combat then return end
		if util.getval(t.hands, self, t) > 0 then
			self:setEffect(self.T_REK_HEKA_EYE_STOCK, 10, {src=self, max_stacks=t:_getMaxTurns(self)})
		end
	end,
	action = function(self, t)
		if not self.in_combat then return nil end
		self:setEffect(self.T_REK_HEKA_EYE_STOCK, 10, {src=self, stacks = t.getTurns(self, t), max_stacks=t:_getMaxTurns(self)})
		return true
	end,
	info = function(self, t)
		return ([[When you spend hands in combat, reduce the time needed to respawn a wandering eye by one turn.  If you already have your maximum number of eyes, up to %d turns can be readied 'in advance'.

Activate this talent to recover an eye %d turns sooner.
]]):tformat(t:_getMaxTurns(self), t:_getTurns(self))
	end,
}

newTalent{
	name = "Eyelemental", short_name = "REK_HEKA_WATCHER_ELEMENT",
	type = {"spell/watcher", 3}, require = mag_req3, points = 5,
	mode = "passive",
	getResists = function(self, t) return self:combatTalentLimit(t, 70, 15, 35) end,
	info = function(self, t)
		return ([[When an eye enters combat, it attunes to a random element, transforming its Eye Lash talent and gaining %d%% resistance to that element.  You gain half the resistance bonus for as long as the eye is alive.]]):tformat(t.getResists(self, t))
	end,
}

newTalent{
	name = "Eye Hatchery", short_name = "REK_HEKA_WATCHER_HATCHERY",
	type = {"spell/watcher", 4}, require = eye_req_slow4, points = 5,
	mode = "passive",
	getBonusEyes = function(self, t) return math.ceil(self:combatTalentLimit(t, 4, 0.5, 2.95)) end,
	getInherit = function(self, t) return self:combatTalentScale(t, 20, 60) end,
	-- implemented in headless-horror/REK_HEKA_HEADLESS_EYES
	info = function(self, t)
		return ([[Your maximum number of wandering eyes is increased by %d.
In addition, your eyes inherit %d%% of your spellpower and gain a bonus to damage and resist penetration equal to %d%% of your best bonuses.]]):tformat(t.getBonusEyes(self, t), t.getInherit(self, t))
	end,
}
