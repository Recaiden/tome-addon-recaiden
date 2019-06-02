newTalent{
   name = "Breach", short_name = "FLN_BLACKSUN_BLACKHOLE",
   type = {"celestial/black-sun", 4},
   require = str_req_high1,
   points = 5,
   mode = "passive",
   info = function(self, t)
      return ([[In progress...]]):format()
   end,
}

newTalent{
   name = "Devour the Pain", short_name = "FLN_BLACKSUN_DEVOUR",
   type = {"celestial/black-sun", 4},
   require = str_req_high2,
   points = 5,
   mode = "passive",
   info = function(self, t)
      return ([[In progress...]]):format()
   end,
}

newTalent{
   name = "Singularity Armor", short_name = "FLN_BLACKSUN_SINGULARITY",
   type = {"celestial/black-sun", 4},
   require = str_req_high3,
   points = 5,
   mode = "passive",
   info = function(self, t)
      return ([[In progress...]]):format()
   end,
}

newTalent{
   name = "Doom Spiral", short_name = "FLN_BLACKSUN_SPIRAL",
   type = {"celestial/black-sun", 4},
   require = str_req_high4,
   points = 5,
   random_ego = "attack",
   cooldown = 9,
   positive = 15,
   tactical = { ATTACKAREA = {LIGHT = 2} },
   range = 0,
   radius = 2,
   requires_target = true,
   target = function(self, t)
      return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t)}
   end,
   getOuterDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.5, 1.3) end,
   getInnerDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.3, 1.5) end,
   getShield = function(self, t) return self:combatTalentSpellDamage(t, 35, 220) end,
   action = function(self, t)
      local tg1 = self:getTalentTarget(t) tg1.radius = 1
      local tg2 = self:getTalentTarget(t)

      -- Gravity pull
      self:addParticles(Particles.new("meleestorm", 2, {radius=2, img="spinningwinds_black"}))
      self:project(tg2, self.x, self.y, function(px, py, tg, self)
		      local target = game.level.map(px, py, Map.ACTOR)
		      if target and target ~= self then
			 self:attackTarget(target, DamageType.REK_FLN_GRAVITY_PULL, t.get2Damage(self, t), true)
		      end
      end)

      -- Physical hit
      local absorbed = 0
      self:addParticles(Particles.new("meleestorm", 1, {img="spinningwinds_red"}))
      self:project(tg1, self.x, self.y, function(px, py, tg, self)
		      local target = game.level.map(px, py, Map.ACTOR)
		      if target and target ~= self then
			 hitted = self:attackTarget(target, nil, t.get1Damage(self, t), true)
			 if hitted then absorbed = absorbed + 1 end
		      end
      end)

      --Shield
      local multShield = 2-0.5^absorbed
      self:setEffect(self.EFF_DAMAGE_SHIELD, 5, {color={0xff/255, 0x3b/255, 0x3f/255}, power=self:spellCrit(t.getShield(self, t)*multShield)})
      
      return true
   end,
   info = function(self, t)
      return ([[Infuse your weapon with overwhelming gravitational power while spinning around.
		All creatures within radius 2 take %d%% weapon damage as physical (gravity) and are pulled closer.
		Then, all adjacent creatures take %d%% weapon damage.  This second strike shields you for between %d and %d, increasing with more enemies hit.  The shield lasts for 2 turns.]]):
	 format(t.getOuterDamage(self, t) * 100,
		t.getInnerDamage(self, t) * 100,
		t.getShield(self, t), t.getShield(self, t)*2)
   end,
}
