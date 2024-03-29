local Emote = require "engine.Emote"

newTalent{
	name = "Tenebrous Reconstruction", short_name = "REK_HOLLOW_SHADOW_HEAL",
	type = {"undead/shadow-magic", 1}, require = undeads_req1, points = 5,
	cooldown = 16,
	use_only_arcane = 3,
	tactical = { HEAL = 2 },
	getHeal = function(self, t) return 40 + self:combatTalentMindDamage(t, 10, 520) end,
	is_heal = true,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
      self:heal(self:mindCrit(t.getHeal(self, t)), self)
      self:attr("allow_on_heal", -1)
      if core.shader.active(4) then
				self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healarcane", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0, beamColor1={0x8e/255, 0x2f/255, 0xbb/255, 1}, beamColor2={0xe7/255, 0x39/255, 0xde/255, 1}, circleDescendSpeed=4}))
				self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healarcane", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0, beamColor1={0x8e/255, 0x2f/255, 0xbb/255, 1}, beamColor2={0xe7/255, 0x39/255, 0xde/255, 1}, circleDescendSpeed=4}))
      end
      game:playSoundNear(self, "talents/heal")
      return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		return ([[Reshapes your body with psychomagical forces, reconstructing it to a default state, healing for %d life.
Mindpower: increases healing.]]):tformat(heal)
	end,
}

newTalent{
	name = "Abyssal Doorway", short_name = "REK_HOLLOW_SHADOW_PHASE_DOOR",
	type = {"undead/shadow-magic", 2}, require = undeads_req2, points = 5,
	hate = 8,
	cooldown = function(self, t) return 12 end,
	tactical = teleport_tactical,
	range = function(self, t) return self:combatTalentScale(t, 5, 15) end,
	is_teleport = true,
	radius = function(self, t) return math.max(0, 7 - math.floor(self:getTalentLevel(t))) end,
	target = function(self, t)
		local old_block_path = engine.Target.defaults.block_path
		local tg = {
			type="ball", nolock=true, pass_terrain=true, nowarning=true, range=self:getTalentRange(t), radius=self:getTalentRadius(t), requires_knowledge=false,
			block_path=function(typ, lx, ly, for_highlights)
				if not self:hasLOS(lx, ly) and not old_block_path(typ, lx, ly, for_highlights) then
					return false, "unknown", true
				else
					return old_block_path(typ, lx, ly, for_highlights) end
		end}
		return tg
	end,
	is_teleport = true,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		
		-- Check LOS
		if not self:hasLOS(x, y) and rng.percent(35 + (game.level.map.attrs(self.x, self.y, "control_teleport_fizzle") or 0)) then
			game.logPlayer(self, "The teleport fizzles and works randomly!")
			x, y = self.x, self.y
			range = self:getTalentRange(t)
		end
		if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
			game.logPlayer(self, "You may only teleport to an open space.")
			return nil
		end
		local __, x, y = self:canProject(tg, x, y)
		local teleport = self:getTalentRadius(t)
		
		game.level.map:particleEmitter(x, y, 1, "generic_teleport", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
		
		if not self:teleportRandom(x, y, teleport) then
			game.logSeen(self, "Your gate fails!")
		end
		
		game.level.map:particleEmitter(self.x, self.y, 1, "generic_teleport", {rm=0, rM=0, gm=180, gM=255, bm=180, bM=255, am=35, aM=90})
		game:playSoundNear(self, "talents/teleport")
		
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local range = self:getTalentRange(t)
		return ([[Teleports you within a range of up to %d.  You arrive within %d grids of a targeted space.
If the target area is not in line of sight, there is a chance you will instead teleport randomly.]]):tformat(range, radius)
	end,
}

newTalent{
	name = "Countless Shades", short_name = "REK_HOLLOW_SHADOW_FADE",
	type = {"undead/shadow-magic",3},
	require = undeads_req3,
	points = 5,
	mode = "passive",
	cooldown = function(self, t) return math.max(3, 8 - self:getTalentLevelRaw(t)) end,
	getChance = function(self, t)
		return math.min(66, 10 + self:combatTalentStatDamage(t, "wil", 10, 40))
	end,
	--callbackOnHit = function(self, t, cb, src)
	-- happen on TakeDamage instead of Hit to pre-empt Shadow Decoy
	callbackOnTakeDamage = function (self, t, src, x, y, type, dam, tmp, no_martyr)
		
		if dam >= (self.life - self.die_at) then
			if not self:isTalentCoolingDown(t) and rng.percent(t.getChance(self, t)) then
				-- successful reform
				dam = 0
				self.life = self.max_life
				game.logSeen(self, "%s fades for a moment and then reforms whole again!", self.name:capitalize())
				game.level.map:particleEmitter(self.x, self.y, 1, "teleport_out")
				game:playSoundNear(self, "talents/heal")
				game.level.map:particleEmitter(self.x, self.y, 1, "teleport_in")
				self:startTalentCooldown(t)
				return {stopped=0}
			else
				-- try to transfer to a new shadow
				if game.party and game.party:hasMember(self) then
					local goat = nil
					for act, def in pairs(game.party.members) do
						if act.summoner and act.summoner == self and act.subtype == "shadow" then
							if not goat or goat.life < act.life then
								goat = act
							end
						end
					end
					if goat then
						local tx, ty, sx, sy = goat.x, goat.y, self.x, self.y
						local life_prop = goat.life / goat.max_life
						goat.x = nil goat.y = nil
						self.x = nil self.y = nil
						goat:move(sx, sy, true)
						self:move(tx, ty, true)
						goat.can_reform = false
						goat:die(self, "was sacrificed for their master")
						self.life = self.max_life * life_prop
						dam = 0
						game.logSeen(self, "%s is struck down but then reforms; it was only a shadow that died!", self.name:capitalize())
						if self.player then
							self:setEmote(Emote.new("Fools, that was only my shadow!", 45))
							world:gainAchievement("AVOID_DEATH", self)
						end
									return {stopped=0}
					end
				end
			end
		end
		return {dam=dam}
	end,
	info = function(self, t)
		return ([[If hit by damage that would kill you, you have a %d%% chance to instead reform fully healed.  This has a cooldown.

Willpower: improves reform chance.

If you fail to reform, you will instead swap places with your healthiest shadow, which dies in your stead.  This can happen even if this talent is on cooldown.  If you have no shadows left, you die normally.]]):tformat(t.getChance(self, t))
end,
}

newTalent{
	name = "Umbral Misdirection", short_name = "REK_HOLLOW_SHADOW_SWAP",
	type = {"undead/shadow-magic", 4}, require = undeads_req4, points = 5,
	cooldown = function(self, t) return 0 end,
	hate = 5,
	no_energy = true,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 15, 1)) end,
	on_pre_use = function(self, t) return self:callTalent(self.T_CALL_SHADOWS, "nbShadowsUp") > 0 end,
	action = function(self, t) --closest friend will be a shadow almost all the time
		local tg = {type="hit", nolock=true, pass_terrain = true, first_target="friend", range=self:getTalentRadius(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, target.x, target.y) > self:getTalentRadius(t) then return nil end
		if target.summoner ~= self or not target.is_doomed_shadow then return end
		
		-- Displace
		local tx, ty, sx, sy = target.x, target.y, self.x, self.y
		target.x = nil target.y = nil
		self.x = nil self.y = nil
		target:move(sx, sy, true)
		self:move(tx, ty, true)
		if self:attr("defense_on_teleport") or self:attr("resist_all_on_teleport") or self:attr("effect_reduction_on_teleport") then
			self:setEffect(self.EFF_OUT_OF_PHASE, 4, {})
		end
		
		return true
	end,
	info = function(self, t)
		return ([[There is no difference between you and your shadows.  One can freely become the other.
		You can target a shadow in radius %d and instantly trade places with it.]]):tformat(self:getTalentRadius(t))
	end,
}
