newTalent{
	name = "Scorn", short_name = "REK_MTYR_SCOURGE_INFEST",
	extra_image_sane = "talents/rek_mtyr_scourge_infest_sane.png",
	extra_image_semisane = "talents/rek_mtyr_scourge_infest_sane.png",
	extra_image_insane = "talents/rek_mtyr_scourge_infest.png",
	type = {"demented/scourge", 1},
	require = martyr_req1,
	points = 5,
	cooldown = 5,
	range = 1,
	insanity = -5,
	is_melee = true,
	requires_target = true,
	tactical = { ATTACK = 1, DISEASE = 1 },
	speed = "weapon",
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 5)) end,
	getHitDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.0) end,
	getDotDamage = function(self, t) return self:combatTalentMindDamage(t, 4, 52) end,
	on_learn = function(self, t)
		self:attr("show_shield_combat", 1)
	end,
	on_unlearn = function(self, t)
		self:attr("show_shield_combat", -1)
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		if not target then return end
		
		doMartyrWeaponSwap(self, "melee", true)
		
		local dam = self:mindCrit(t.getDotDamage(self, t))
		local ramp = 1
		local fail = 0
		local lifesteal = 0
		--DoT
		if self:knowTalent(self.T_REK_MTYR_SCOURGE_SPROUTING) then
			local t2 = self:getTalentFromId(self.T_REK_MTYR_SCOURGE_SPROUTING)
			ramp = ramp + t2.getRamp(self, t2)
			if amInsane(self) then
				fail = t2.getFail(self, t2)
			end
		end
		if self:knowTalent(self.T_REK_MTYR_SCOURGE_SHARED_FEAST) then
			local t4 = self:getTalentFromId(self.T_REK_MTYR_SCOURGE_SHARED_FEAST)
			lifesteal = lifesteal + t4.getDrain(self, t4)
		end
		
		local shield, shield_combat = self:hasShield()
		local weapon = self:hasMHWeapon() and self:hasMHWeapon().combat or self.combat
		local hit = false
		if not shield then
			hit = self:attackTarget(target, nil, 1, true)
		else
			hit = self:attackTargetWith(target, weapon, nil, 1)
			if self:attackTargetWith(target, shield_combat, nil, 1) or hit then hit = true end
			if hit then game:playSoundNear(self, self.on_hit_sound or "actions/melee_hit_squish") end
		end
		if hit and not target.dead then
			target:setEffect(target.EFF_REK_MTYR_SCORN, 5, {damage={{power=dam, dur_m=0}}, ramp=ramp, fail=fail, lifesteal=lifesteal, src=self})
			-- insanityBonus
			if amInsane(self) then
				if target:canBe("slow") then
					target:setEffect(target.EFF_CRIPPLE, t.getDuration(self, t), {apply_power=self:combatMindpower()})
				end
			end
		end
		
		return true
	end,
	
	info = function(self, t)
		return ([[Strike an enemy in melee, and, if you hit, afflict the target with Scorn, which does %d mind damage per turn for %d turns (#SLATE#no save#LAST#).  Scorn is considered a disease (but ignores immunity).  This will also attack with your shield if you have one equipped.
Mindpower: increases damage.

#GREEN#Our Gift:#LAST# The target will be crippled (#SLATE#Mindpower vs. Physical#LAST#) for %d turns.
]]):tformat(t.getDotDamage(self, t), 5, t.getDuration(self, t))
	end,
}

newTalent{
   name = "Mental Collapse", short_name = "REK_MTYR_SCOURGE_SPROUTING",
   type = {"demented/scourge", 2},
   require = martyr_req2,
   points = 5,
   mode = "passive",
   getRamp = function(self, t) return self:combatTalentScale(t, 0.08, 0.3) end,
   getFail = function(self, t) return math.min(33, self:combatTalentScale(t, 10, 20)) end,
   info = function(self, t)
      return ([[The knowledge of their failure compounds over time, increasing the mind damage Scorn deals by %d%% each turn as long as you are within 3 spaces of them.

#GREEN#Our Gift:#LAST# Scorn also gives the victim a %d%% chance to fail to use talents.]]):tformat(t.getRamp(self, t)*100, t.getFail(self, t))
   end,
}

newTalent{
	name = "Challenging Call", short_name = "REK_MTYR_SCOURGE_GRASPING_TENDRILS",
	extra_image_sane = "talents/rek_mtyr_scourge_grasping_tendrils_sane.png",
	extra_image_semisane = "talents/rek_mtyr_scourge_grasping_tendrils_sane.png",
	extra_image_insane = "talents/rek_mtyr_scourge_grasping_tendrils.png",
	type = {"demented/scourge", 3},
	require = martyr_req3,
	points = 5,
	cooldown = 8,
	insanity = 10,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 180) end,
	range = 10,
	requires_target = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 3, 8)) end,
	target = function(self, t) return {type="cone", range=0, radius=self:getTalentRange(t)} end,
	tactical = { CLOSEIN = 2 },
	action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y = self:getTarget(tg)
      if not x or not y then return nil end
      
      local weapondam = t.getDamage(self, t)
      self:project(
         tg, x, y,
         function(px, py)
            local act = game.level.map(px, py, Map.ACTOR)
            if act and self:reactionToward(act) < 0 then
               local hit = false
               for eff_id, p in pairs(act.tmp) do
                  local e = act.tempeffect_def[eff_id]
                  if e.subtype.disease then hit = true break end
               end               
               if hit and act:canBe("knockback") then
                  act:pull(self.x, self.y, self:getTalentRange(t))
                  if amSane(self) then
                     self:addParticles(Particles.new("tentacle_pull", 1, {range=core.fov.distance(self.x, self.y, px, py), dir=math.deg(math.atan2(py-self.y, px-self.x)+math.pi/2)}))
                  else
                     game.level.map:particleEmitter(px, py, 1, "shout", {additive=true, life=10, size=3, distorion_factor=0.5, radius=1, nb_circles=8, rm=0.8, rM=1, gm=0.4, gM=0.5, bm=0.1, bM=0.2, am=0.4, aM=0.6})
                  end
                  -- insanity bonus
                  if amInsane(self) then
                     act:setEffect(act.EFF_PINNED, 1, {src=self})
                  end
               end
            end
         end)
      
      return true
   end,
   info = function(self, t)
      return ([[Demand that your foes return to face you rather than flee!  All diseased enemies in a cone of radius %d are pulled towards you #SLATE#(checks knockback resistance)#LAST#.

#GREEN#Our Gift:#LAST# All targets pulled in are then pinned for 1 turn #SLATE#(no save)#LAST#]]):tformat(self:getTalentRange(t), damDesc(self, DamageType.BLIGHT, t.getDamage(self, t) * 100))
   end,
}

newTalent{
   name = "Triumphant Vitality", short_name = "REK_MTYR_SCOURGE_SHARED_FEAST",
   type = {"demented/scourge", 4},
   require = martyr_req4,
   points = 5,
   mode = "passive",
   getDrain = function(self, t) return math.min(1.0, self:combatTalentScale(t, 0.2, 0.45)) end,
   info = function(self, t)
      return ([[Whenever your Scorn effect deals damage, you heal for %d%% of the damage done.  

#GREEN#Our Gift:#LAST# The damage dealt by Scorn is increased by 10-50%% based on your current insanity.]]):tformat(100*t.getDrain(self, t))
   end,
}
