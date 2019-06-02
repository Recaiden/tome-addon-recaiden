--    Small damage
--    Stun and lower bleed resist.
newTalent{
   name = "Brutalize", short_name = "FLN_DARKSIDE_SLAM",
   type = {"celestial/darkside", 1},
   require = divi_req1,
   points = 5,
   cooldown = 6,
   positive = 5,
   tactical = { ATTACK = { weapon = 1 }, DISABLE = { stun = 2 } },
   range = 1,
   requires_target = true,
   is_melee = true,
   getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
   target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.3, 0.6) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not target or not self:canProject(tg, x, y) then return nil end
      local hit = self:attackTarget(target, nil, self:combatTalentWeaponDamage(t, 1, 1.5), true)
      
      if hit then
	 if target:canBe("stun") then
	    target:setEffect(target.EFF_FLN_BLEED_VULN, t.getDuration(self, t), {apply_power=self:combatPhysicalpower()})
	 else
	    game.logSeen(target, "%s resists the brutality!", target.name:capitalize())
	 end
      end
      
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      return ([[Hits the target with your weapon, doing %d%% damage. If the attack hits, the target is stunned (#SLATE#Physical power vs. Physical#LAST#) for %d turns and has their bleed resistance reduced by 50%%

#{italic}#It may not bleed, exactly, but you'll make it hurt.#{normal}#]])
	 :format(100 * damage, t.getDuration(self, t))
   end,
}

newTalent{
   name = "Lunacy", short_name = "FLN_DARKSIDE_POWER",
   type = {"celestial/darkside", 2},
   mode = "passive",
   points = 5,
   require = divi_req2,
   -- called in _M:combatSpellpower in mod\class\interface\Combat.lua
   getSpellpower = function(self, t) return self:combatTalentScale(t, 15, 30, 0.75) end,
   getMindpower = function(self, t) return self:combatTalentScale(t, 15, 30, 0.75) end,
   
   info = function(self, t)
      local spellpower = t.getSpellpower(self, t)
      local mindpower = t.getMindpower(self, t)
      return ([[Your curse feeds on the magic, which in turn is powered by the curse.
You gain a bonus to Spellpower equal to %d%% of your Willpower.
You gain a bonus to Mindpower equal to %d%% of your Magic.

#{italic}#Something is not quite right inside you.  Your holy spells are somehow twisted.  Your bloody rites are somehow sacred.#{normal}#]]):format(spellpower, mindpower)
   end,
}


newTalent{
   name = "Flee the Sun", short_name = "FLN_DARKSIDE_BLINK",
   type = {"celestial/darkside", 3},
   require = divi_req3,
   points = 5,
   positive = 20,
   cooldown = 16,
   tactical = { CLOSEIN = 2, ESCAPE = 2 },
   range = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7, 0.5, 0, 1)) end,
   requires_target = true,
   is_teleport = true,
   target = function(self, t)
      return {type="hit", nolock=true, range=self:getTalentRange(t)}
   end,
   getBlastTarget = function(self, t)
      return {type="ball", range=0, radius=1, selffire=false, talent=t}
   end,
   getDamage = function(self, t) return self:combatTalentSpellDamage(t, 28, 200) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      if not x or not y then return nil end
      -- allow teleporting through walls
      --if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
	 --game.logPlayer(self, "You do not have line of sight.")
	 --return nil
      --end
      local _ _, x, y = self:canProject(tg, x, y)

      --TODO swap with darkness particles
      game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
      
      if not self:teleportRandom(x, y, 1) then
	 game.logSeen(self, "%s's teleportation fizzles!", self.name:capitalize())
      else
	 game.logSeen(self, "%s emerges from the darkness!", self.name:capitalize())

	 local btg = t.getBlastTarget(self, t)
	 local dam = self:spellCrit(t.getDamage(self, t))
	 self:project(btg, self.x, self.y, DamageType.DARKNESS, {daze=75, dam=rng.avg(dam / 3, dam, 3)})
	 --TODO particle effect
      	 game.level.map:particleEmitter(self.x, self.y, 1, "temporal_teleport")
      end
   
      game:playSoundNear(self, "talents/teleport")
      return true
   end,
   
   info = function(self, t)
      local range = t.range(self, t)
      return ([[Fade into the darkness and reappear elsewhere within range %d.  When you emerge from the shadows, you unleash a burst of darkness, dealing %d damage to enemies in radius 1.]]):format(range, 3)
   end,
}

newTalent{
   name = "Final Sunbeam", short_name = "FLN_DARKSIDE_SUNSET",
   type = {"celestial/darkside", 4},
   require = divi_req4,
   points = 5,
   cooldown = 20,
   range = 0,
   target = function(self, t)
      return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
   end,
   radius = function(self, t)
      return math.max(1, math.min(10, math.floor(self:getPositive() / 10)))
   end,
   getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.0, 1.5) end,
   getMult = function(self, t) return self:combatTalentScale(t, 1.0, 2.0) end,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local damage = t.getDamage(self, t) * (1+(t.getMult(self, t) * self:getPositive() / 100))
      
      self:project(tg, self.x, self.y, function(px, py, tg, self)
		      local target = game.level.map(px, py, Map.ACTOR)
		      if target and target ~= self then
			 self:attackTarget(target, nil, damage)
			 if target:canBe("stun") then
			    local power = math.max(self:combatSpellpower(), self:combatMindpower(), self:combatPhysicalpower())
			    target:setEffect(target.EFF_DAZED, 3, {apply_power=power})
			 end
		      end
      end)
      
      self:addParticles(Particles.new("meleestorm", 2, {radius=t.radius(self, t), img="spinningwinds_black"}))
      if not self:attr("zero_resource_cost") and not self:attr("force_talent_ignore_ressources") then self:incPositive(-1 * self:getPositive()) end
      self:setEffect(self.EFF_FLN_NO_LIGHT, 5)
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)*100
      local mult = t.getMult(self, t)
      return ([[Put all of your physical and magical might into one devastating attack.
Strike all adjacent enemies for %d%% damage and daze them (using your highest power) for 3 turns.

Using this talent consumes all of your Positive Energy and prevents you from generating positive energy for 5 turns.
Every point of positive energy increases the damage by %.2f%%.
Every 10 points of positive energy increase the radius by 1 (up to 10).]]):format(damage, mult)
   end,
}
