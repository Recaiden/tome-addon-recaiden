newTalent{
	name = "Sling Practice", short_name = "REK_MTYR_VAGABOND_SLING_PRACTICE",
	type = {"demented/vagabond", 1},
	require = sling_reqMaster,
	points = 5,
	mode = "passive",
	getDamage = function(self, t) return 30 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 1.8 end,
	getReload = function(self, t) return self:getTalentLevel(t) >= 2 and 1 or 0 end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, 'ammo_mastery_reload', t.getReload(self, t))
	end,
	callbackOnArcheryAttack = function(self, t, target, hitted)
		if self:reactionToward(target) >= 0 then return end
		if hitted then
			self:incInsanity(5)
		end
	end,
	callbackOnWear = function(self, t, o, fBypass)
		if not o then return end
		if not o.wielder then return end
		if not o.wielder.talents_types_mastery then return end

		if o.wielder.talents_types_mastery["demented/vagabond"] and not o.wielder.talents_types_mastery["demented/chivalry"] then
			o.wielder.talents_types_mastery["demented/chivalry"] = o.wielder.talents_types_mastery["demented/vagabond"]
		end
		if o.wielder.talents_types_mastery["demented/chivalry"] and not o.wielder.talents_types_mastery["demented/vagabond"] then
			o.wielder.talents_types_mastery["demented/vagabond"] = o.wielder.talents_types_mastery["demented/chivalry"]
		end
	end,
	info = function(self, t)
		return ([[You can't really call it 'mastery', but you've used a sling before, along with a variety of other weapons.
This increases Physical Power by %d and weapon damage by %d%% when using a sling and increases your reload rate by %d.

Whenever you hit with a ranged weapon, you will gain #INSANE_GREEN#5 insanity.#LAST#

#YELLOW#Every level in this talent allows you to learn a Chivalry talent for free.#LAST#]]):format(t.getDamage(self, t), 100*t.getPercentInc(self, t), t.getReload(self, t))
	end,
}

newTalent{
	name = "Stagger Shot", short_name = "REK_MTYR_VAGABOND_STAGGER_SHOT",
	type = {"demented/vagabond", 2},
	require = sling_req2,
	points = 5,
	cooldown = 10,
	range = archery_range,
	speed = "archery",
	tactical = { ATTACK = { weapon = 1 } },
	requires_target = true,
	on_pre_use = function(self, t, silent) return martyrPreUse(self, t, silent, "sling") end,
	getDist = function(self, t) return math.floor(self:combatTalentLimit(t, 11, 4, 8)) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.5, 2.8) end,
	archery_onhit = function(self, t, target, x, y)
		if self:reactionToward(target) < 0 then
			self:incInsanity(5)
		end


		if not target or not target:canBe("knockback") then return end
		-- Frog Knockback
		local function doConeKnockback(angle, margin)
			-- get a cone of tiles
			-- organize them by distance
			-- pick the furthest (with a bit of a margin) ones randomly
			local margin = margin or 1
			local moved = false
			local cone_x, cone_y = target.x, target.y
			
			local spots = {}
			self:project({type="cone", cone_angle = angle, radius=4}, cone_x, cone_y, function(tx, ty)
										 if not game.level.map:checkAllEntities(tx, ty, "block_move", self) then
											 local dX, dY = self.x - tx, self.y - ty
											 local moveDist = (dX * dX + dY * dY) ^ 0.5
											 if core.fov.distance(x, y, tx, ty) <= 4 then spots[#spots+1] = {x=tx, y=ty, dist=moveDist} end
										 end
																																								end)
			table.sort(spots, "dist")
			local farSpots = {}
			local maxDist = nil
			if #spots ~= 0 then
				for i = #spots, 1, -1 do
					maxDist = maxDist or spots[i].dist
					if maxDist - spots[i].dist < margin then
						farSpots[#farSpots + 1] = {x = spots[i].x, y = spots[i].y}
					end
				end
				
				if #farSpots ~= 0 then
					local spotPicked = rng.tableRemove(farSpots)
					local mx, my = spotPicked.x, spotPicked.y
					
					if mx and (mx ~= target.x or my ~= target.y) then
						moved = true
						target:move(mx, my, true)
						target.last_special_movement = game.turn	
					end
				end
			end
			return moved
		end
		local moved = doConeKnockback(65)
		if not moved then doConeKnockback(200, .4) end
		--target:knockback(self.x, self.y, t.getDist(self, t))
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, 'martyr_swap', 1)
	end,
	action = function(self, t)
		doMartyrWeaponSwap(self, "sling", true)
		local targets = self:archeryAcquireTargets(nil, {one_shot=true, no_energy = true})
		if not targets then return end
		self:archeryShoot(targets, t, nil, {mult=t.getDamage(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[You ready a sling shot with all your strength.
This shot does %d%% weapon damage, gives you an extra #INSANE_GREEN#5 insanity#LAST#, and knocks back your target %d spaces (#SLATE#checks knockback resistance#LAST#), even when things might seem to be in the way.

Learning this talent allows martyr talents to instantly and automatically swap to your alternate weapon set when needed.

#{italic}#Keep your distance!  It's...for your own good.#{normal}#

#YELLOW#Every level in this talent allows you to learn a Chivalry talent for free.#LAST#]]):
      format(t.getDamage(self, t) * 100, t.getDist(self, t))
   end,
}

newTalent{
	name = "Tainted Bullets", short_name = "REK_MTYR_VAGABOND_TAINTED_BULLETS",
	type = {"demented/vagabond", 3},
	require = sling_req3,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	tactical = { BUFF = 2 },
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 3, 20) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "archery_pass_friendly", 1)
	end,
	callbackOnArcheryAttack = function(self, t, target, hitted)
		if hitted and target and not target.dead then
			if not target:hasProc("martyr_unslowable") then
				target:setEffect(target.EFF_MARTYR_STACKING_SLOW, 5, {power=t.getDamage(self, t), src=self})
			end
		end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fire")
		local ret = {
		}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[You make unusual modifications to your sling bullets, causing them to inflict a 10%% movement speed slow (#SLATE#no save#LAST#) that stacks up to 5 times and deals %0.2f mind damage per stack. This counts as a disease (but ignores immunity).  If the target breaks free from the slow, they'll be immune to it for the next five turns. 
Mindpower: increases damage.

All your shots, including bullets from Shoot and other talents, now travel around friendly targets without causing them harm (regardless of whether this talent is sustained).

#YELLOW#Every level in this talent allows you to learn a Chivalry talent for free.#LAST#]]):format(damDesc(self, DamageType.MIND, t.getDamage(self, t)))
   end,
}

newTalent{
   name = "Hollow Shell", short_name = "REK_MTYR_VAGABOND_HOLLOW_SHELL",
   type = {"demented/vagabond", 4},
   require = sling_req4,
   points = 5,
   mode = "passive",
   getCritResist = function(self, t) return self:combatTalentScale(t, 11, 33, 0.66) end,
   passives = function(self, t, p)
      self:talentTemporaryValue(p, "ignore_direct_crits", t.getCritResist(self, t))
   end,
   info = function(self, t)
      return ([[Your body's vital organs are indistinct or perhaps missing.
Direct critical hits againts you deal %d%% less extra damage.

#{italic}#Nothing's ever going to hurt me worse than #GREEN#we#LAST# already have.#{normal}#

#YELLOW#Every level in this talent allows you to learn a Chivalry talent for free.#LAST#]]):format(t.getCritResist(self, t))
   end,
}
