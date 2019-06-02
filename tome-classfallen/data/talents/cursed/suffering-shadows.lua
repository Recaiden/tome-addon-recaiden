newTalent{
   name = "Twisted Shadows", short_name = "FLN_SHADOW_TWISTING_SHADOWS",
   type = {"cursed/suffering-shadows", 1},
   require = cursed_wil_req_high1,
   points = 5,
   mode = "passive",
   info = function(self, t)
      return ([[In progress...]]):format()
   end,
}

newTalent{
   name = "Shadow Guardians", short_name = "FLN_SHADOW_GUARDING_SHADOWS",
   type = {"cursed/suffering-shadows", 2},
   require = cursed_wil_req_high2,
   points = 5,
   points = 5,
   cooldown = 10,
   mode = 'sustained',
   no_npc_use = true,
   --count shadows in party
   getShadows = function(self, t)
      local shadowsCount = 0
      for _, actor in pairs(game.level.entities) do
	 if actor.summoner and actor.summoner == self and actor.subtype == "shadow" then shadowsCount = shadowsCount + 1 end
      end
      return shadowsCount
   end,
   --values for resists and affinity
   getLightResist = function(self, t) return -15 end,
   getDarkResist = function(self, t) return self:combatTalentScale(t, 10, 25) end,
   getAffinity = function(self, t) return self:combatTalentScale(t, 10, 25) end,
   getAllResScale = function(self, t) return self:combatTalentScale(t, 2, 4) end,
   getAllResist = function(self, t) return t.getAllResScale(self, t) * t.getShadows(self, t) end, 
   --activate effects
   activate = function(self, t)
      local ret = {
	 shadowres = self:addTemporaryValue("resists", {all=t.getAllResist(self, t)}),
	 res = self:addTemporaryValue("resists", {[DamageType.LIGHT]=t.getLightResist(self, t), [DamageType.DARKNESS]=t.getDarkResist(self, t)}),
	 aff = self:addTemporaryValue("damage_affinity", {[DamageType.DARKNESS]=t.getAffinity(self, t)}),
      }
      return ret
   end,
   --callbacks
   callbackOnPartyAdd = function(self, t)
      local p = self:isTalentActive(t.id)
      if p.shadowres then self:removeTemporaryValue("resists", p.shadowres) end
      p.shadowres = self:addTemporaryValue("resists", {all=t.getAllResist(self, t)})
   end,
   callbackOnPartyRemove = function(self, t)
      local p = self:isTalentActive(t.id)
      game:onTickEnd(function()
	    if p.shadowres then self:removeTemporaryValue("resists", p.shadowres) end
	    p.shadowres = self:addTemporaryValue("resists", {all=t.getAllResist(self, t)})
      end)
   end,
   --daectivate effects
   deactivate = function(self, t, p)
      self:removeTemporaryValue("resists", p.shadowres)
      self:removeTemporaryValue("resists", p.res)
      self:removeTemporaryValue("damage_affinity", p.aff)
      return true
   end,
   info = function(self, t)
      return ([[You draw distant from the sun, and sink into the shadows of your past.  The line between you and your shadows begins to blur.
		You lose %d%% light resistance, but gain %d%% darkness resistance and affinity. You also gain %0.2f%% all resistance for each shadow in your party.]]):
	 format(t.getLightResist(self, t), t.getDarkResist(self, t), t.getAllResScale(self, t))
   end,   
}

newTalent{
   name = "Shadow Madness", short_name = "FLN_SHADOW_MADNESS",
   type = {"cursed/suffering-shadows", 3},
   require = cursed_wil_req_high3,
   points = 5,
   range = 3,
   cooldown = 14,
   hate = 6,
   getDuration = function(self, t) return self:combatTalentScale(t, 2, 6) end,
   action = function(self, t)
      local tgts = {}
      local seen = {}

      -- Collect all enemies within range of any shadow
      for _, actor in pairs(game.level.entities) do
	 if actor.summoner and actor.summoner == self and actor.subtype == "shadow" then
	    self:project({type="ball", radius=self:getTalentRange(t)}, actor.x, actor.y, function(px, py)
		  local tgt = game.level.map(px, py, Map.ACTOR)
		  if tgt and self:reactionToward(tgt) < 0 and not seen[tgt.uid] then
		     tgts[#tgts+1] = tgt
		     seen[tgt.uid] = true
		  end
	    end)   
	 end
      end

      -- Gloom them
      for _, target in tgts do
	 if  target:checkHit(mindpower, target:combatMentalResist(), 5, 95, 15) then
	    local effect = rng.range(1, 3)
	    if effect == 1 then
	       -- confusion
	       if target:canBe("confusion") and not target:hasEffect(target.EFF_GLOOM_CONFUSED) then
		  target:setEffect(target.EFF_GLOOM_CONFUSED, t.getDuration(self, t), {power=70})
	       end
	    elseif effect == 2 then
	       -- stun
	       if target:canBe("stun") and not target:hasEffect(target.EFF_GLOOM_STUNNED) then
		  target:setEffect(target.EFF_GLOOM_STUNNED, t.getDuration(self, t), {})
	       end
	    elseif effect == 3 then
	       -- slow
	       if target:canBe("slow") and not target:hasEffect(target.EFF_GLOOM_SLOW) then
		  target:setEffect(target.EFF_GLOOM_SLOW, t.getDuration(self, t), {power=0.3})
	       end
	    end
	 end
      end
   end,
   info = function(self, t)
      local dur = t.getDuration(self, t)
      return ([[Channel your raw anguish through your shadows, causing enemies near them to be overcome by gloom (#SLATE#Mindpower vs. Mental#LAST#) for %d turns, inflicting stun, slow, or confusion at random.]]):format(dur)
   end,
}

newTalent{
   name = "Shadow Reave", short_name = "FLN_SHADOW_SHADOW_REAVE",
   type = {"cursed/suffering-shadows", 4},
   require = cursed_wil_req_high4,
   points = 5,
   cooldown = 20,
   hate = 18,
   getDuration = function(self, t) return 8 end,
   getResist = function(self, t) return math.ceil(self:combatTalentScale(t, 8, 35)) end,
   info = function(self, t)
      local dur = t.getDuration(self, t)
      local strip = t.getResist(self, t)
      return ([[Rip away a target's shadow and pour in your pain to animate it, summoning a Shadow of Despair for %d turns.

The Shadow of Despair can terrorize foes with various fears.
As long as the shadow persists, the target's resistance to Light and Darkness damage is reduced by %d%%.]]):format(dur, strip)
   end,
}
