local Effects = require "engine.interface.ActorTemporaryEffects"
local Talents = require "engine.interface.ActorTalents"

zephyrArcaneCombat = function(caster, target, tid)
		local talent = caster:getTalentFromId(tid)
		local range = caster:getTalentRange(talent)
		-- same as arcane combat
		local fatigue = (100 + 2 * caster:combatFatigue()) / 100
		if not (caster:attr("force_talent_ignore_ressources")
						or caster:attr("zero_resource_cost")
						or (caster.talent_no_resources and caster.talent_no_resources[tid])) then
			local availableMana = caster:getMana()
			if (talent.mana+2)*fatigue > availableMana then return end
		end
		local l = caster:lineFOV(target.x, target.y)
		l:set_corner_block()
		local lx, ly, is_corner_blocked = l:step(true)
		local target_x, target_y = lx, ly
		while lx and ly and not is_corner_blocked and core.fov.distance(caster.x, caster.y, lx, ly) <= range do
			local actor = game.level.map(lx, ly, engine.Map.ACTOR)
			if actor and (caster:reactionToward(actor) >= 0) then
				break
			elseif game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move") then
				target_x, target_y = lx, ly
				break
			end
			target_x, target_y = lx, ly
			lx, ly = l:step(true)
		end
		local old_cd = caster.talents_cd[tid]
		caster.talents_cd[tid] = nil
		caster:forceUseTalent(tid, {ignore_energy=true, force_target={x=target_x, y=target_y, __no_caster=true}})
		caster.talents_cd[tid] = old_cd
		caster.changed = true
end

local baseDeactivate = Effects.tempeffect_def["EFF_MARKED"].deactivate
Effects.tempeffect_def["EFF_MARKED"].on_merge = function(self, old_eff, new_eff)
	self:removeParticles(old_eff.particle)
	return new_eff
end
Effects.tempeffect_def["EFF_MARKED"].deactivate = function(self, eff)
	local caster = eff.src
	if eff.dur > 0 then
		if caster and caster.knowTalent and caster:knowTalent(caster.T_REK_ZEPHYR_STORM_ARCHER) then
			local tid = caster.T_CHAIN_LIGHTNING
			if caster:knowTalent(tid) then
				zephyrArcaneCombat(caster, self, tid)
			end
		end
	end
	baseDeactivate(self, eff)
end

local base_onhit = Talents.talents_def.T_STEADY_SHOT.archery_onhit
Talents.talents_def.T_STEADY_SHOT.archery_onhit = function(self, t, target, x, y)
	local caster = self
	if caster and caster.knowTalent and caster:knowTalent(caster.T_REK_ZEPHYR_STORM_ARCHER) then
		local tid = caster.T_LIGHTNING
		if caster:knowTalent(tid) then
			zephyrArcaneCombat(caster, target, tid)
		end
	end
	base_onhit(self, t, target, x, y)
end

local base_onhitShoot = Talents.talents_def.T_SHOOT.archery_onhit
Talents.talents_def.T_SHOOT.archery_onhit = function(self, t, target, x, y)
	local caster = self
	if self.mark_steady and caster and caster.knowTalent and caster:knowTalent(caster.T_REK_ZEPHYR_STORM_ARCHER) then
		local tid = caster.T_LIGHTNING
		if caster:knowTalent(tid) then
			zephyrArcaneCombat(caster, target, tid)
		end
	end
	base_onhitShoot(self, t, target, x, y)
end

newTalent{
	name = "Storm Archer", short_name = "REK_ZEPHYR_STORM_ARCHER",
	type = {"spell/lightning-archery", 1}, points = 5, require = spells_req_high1,
	mode = "passive",
	getDamage = function(self, t) return 30 end,
	getPowerConversion = function(self, t) return math.min(1, self:combatTalentScale(t, 0.5, 0.9)) end,
	info = function(self, t)
		return ([[Your arrows serve as a conduit for your electrical magic. Your raw Spellpower is increased by %d%% of your raw Physical Power.
When you consume a Mark, you instantly cast Chain Lightning at the target.
When you hit with Steady Shot, you instantly cast Lightning at the target.
These instant spells only trigger if you know the spell, ignore cooldown, but still cost mana.]]):tformat(t.getPowerConversion(self, t)*100)
	end,
}

newTalent{
	name = "Electric Stamina", short_name = "REK_ZEPHYR_ELECTRIC_STAMINA",
	type = {"spell/lightning-archery", 2}, points = 5, require = spells_req_high2,
	mode = "passive",
	getMana = function(self, t) return self:combatTalentScale(t, 1.2, 3.0) end,
	getPen = function(self, t) return self:combatTalentScale(t, 5, 12.5) end,
	callbackOnArcheryAttack = function(self, t, target, hitted, crit, weapon, ammo, damtype, mult, dam, talent)
		if not hitted then return end
		self:incMana(t:_getMana(self))
		self:setEffect(self.EFF_REK_ZEPHYR_ELECTRIC_STAMINA, 3, {power=t:_getPen(self), src=self})
	end,
	info = function(self, t)
		return ([[Your archery attacks now increase your mana by %0.1f on hit, and give you a %d%% bonus to lightning resistance penetration that stacks up to 5 times.]]):tformat(t.getMana(self, t), t.getPen(self, t))
	end,
}

newTalent{
	name = "Storm Bolts", short_name = "REK_ZEPHYR_STORM_BOLTS",
	type = {"spell/lightning-archery", 3}, points = 5, require = spells_req_high3,
	mana = 15,
	cooldown = 10,
	no_energy = true,
	tactical = { BUFF = 1 },
	getDamage = function(self,t) return self:combatTalentSpellDamage(t, 10, 35) end,
	getDuration = function(self, t) return 5 end,
	action = function(self, t)
		self:setEffect(self.EFF_REK_ZEPHYR_STORM_BOLTS, t:_getDuration(self), {power=t:_getDamage(self), src=self})
		return true
	end,
	info = function(self, t)
		return ([[Infuse your arrows with the essence of lightning for %d turns, turning them into piercing beams that deal %d additional lightning damage with a 25%% chance to daze.
Spellpower: increases damage]]):tformat(t:_getDuration(self), damDesc(self, DamageType.LIGHTNING,t:_getDamage(self)))
	end,
}

newTalent{
	name = "Ride the Lightning", short_name = "REK_ZEPHYR_LIGHTNING_JUMP",
	type = {"spell/lightning-archery", 4}, points = 5, require = spells_req_high4,
	mana = 35,
	cooldown = 18,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 4, 9.2)) end,
	tactical = { CLOSEIN = 2, ESCAPE = 2 },
	requires_target = true,
	getDamage = function(self,t) return self:combatTalentSpellDamage(t, 10, 250) end,
	target = function(self, t) return {type="beam", nolock=true, range=self:getTalentRange(t)} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)

		if not x or not y then return end
		local can, sx, sy, x, y = self:canProject(tg, x, y)
		if not can then return end

		if game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
			game.logPlayer(self, "There is no open space there.")
			return nil
		end

		local ox = self.x
		local oy = self.y
		if not self:teleportRandom(x, y, 0) then
			game.logSeen(self, "There is no path for %s's lightning.", self.name:capitalize())
		else
			tg = {type="beam", range=self:getTalentRange(t), selffire=false, talent=t, x=self.x, y=self.y}
			local dam = self:spellCrit(t.getDamage(self,t))
			self:project(
				tg, ox, oy,
				function(px, py)
					local target = game.level.map(px, py, Map.ACTOR)
					if target then
						target:setEffect(target.EFF_MARKED, 2, {src=self})
					end
				end
			)
			self:project(tg, ox, oy, DamageType.LIGHTNING_DAZE, {dam=rng.avg(dam / 3, dam, 3), daze=50})
			game.level.map:particleEmitter(ox, oy, math.max(math.abs(x-ox), math.abs(y-oy)), "lightning", {tx=x-ox, ty=y-oy})
			game:playSoundNear(self, "talents/lightning")
		end

		return true
	end,
	info = function(self, t)
		return ([[Transport yourself along a bolt of lightning to an empty space. Creatures in your path are struck for %0.2f to %0.2f lightning damage and marked for 2 turns, with a 50%% chance to be dazed.
Spellpower: increases damage]]):tformat(damDesc(self,DamageType.LIGHTNING,t.getDamage(self,t)/3), damDesc(self,DamageType.LIGHTNING,t.getDamage(self,t)))
	end,
}
