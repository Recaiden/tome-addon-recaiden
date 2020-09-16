local Object = require "mod.class.Object"
require "math"

--  1  Harmonic Feedback - Passive, Gain a temporary buff when casting elemental spells
newTalent{
   name = "Harmonic Feedback", short_name = "WANDER_FEEDBACK",
   type = {"celestial/terrestrial_unity", 1},
   require = spells_req1,
   points = 5,
   mode = "passive",

   getSpeed = function(self, t)
      return 2.2
   end,
   getResist = function(self, t)
      return 3 --math.max(1, self:getTalentLevel(t) * 0.67)
   end,
   getHealMod = function(self, t)
      return 15 --self:combatTalentSpellDamage(t, 3, 10)

   end,

   callbackOnTalentPost = function(self, t, ab)
      if not ab.type[1]:find("^celestial/") then return end
      if ab.type[1]:find("/kolal") then
	 self:setEffect(self.EFF_WANDER_KOLAL, 10, {stacks = 1, max_stacks = self:getTalentLevelRaw(t)})
      elseif ab.type[1]:find("/luxam") then
	 self:setEffect(self.EFF_WANDER_LUXAM, 10, {stacks = 1, max_stacks = self:getTalentLevelRaw(t)})
      elseif ab.type[1]:find("/ponx") then
      	 self:setEffect(self.EFF_WANDER_PONX, 10, {stacks = 1, max_stacks = self:getTalentLevelRaw(t)})
      end
   end,
   
   info = function(self, t)
      local speed_flame = t.getSpeed(self, t)
      local res_cold = t.getResist(self, t)
      local hmod_wind = t.getHealMod(self, t)
      local stacks = self:getTalentLevelRaw(t)
      
      return ([[Casting planetary spells gives you charges of planetary energy for 10 turns, stacking up to %d times each
Kolal charges increase your casting and combat speeds by %d%%
Luxam charges increase your resist all by %d%%
Ponx charges increase your healing mod by %d%%]]):format(stacks, speed_flame, res_cold, hmod_wind)
   end,
}


--  4  Elemental Transposition - swap places with one of your elementals
newTalent{
   name = "Elemental Transposition", short_name = "WANDER_SWAP",
   type = {"celestial/terrestrial_unity", 2},
   require = spells_req2,
   points = 5,
   random_ego = "attack",
   negative = 5,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 25, 6)) end, -- Limit > 5
   range = 10,
   requires_target = true,
   np_npc_use = true,
   no_energy = true;

   on_pre_use = function(self, t, silent)
      if game.party and game.party:hasMember(self) then
	 for act, def in pairs(game.party.members) do
	    if act.summoner and act.summoner == self and act.type == "elemental" then
	       return true
	    end
	 end
      end
      if not silent then game.logPlayer(self, "You require an ally to swap places with") end
      return false
   end,
   
   action = function(self, t)
      local tg = {type="hit", range=self:getTalentRange(t), talent=t}
      local tx, ty, target = self:getTarget(tg)
      if not tx or not ty or not target or not target.summoner or target.summoner ~= self or not target.type == elemental then return nil end
      
      -- Displace
      game.level.map:remove(self.x, self.y, Map.ACTOR)
      game.level.map:remove(target.x, target.y, Map.ACTOR)
      game.level.map(self.x, self.y, Map.ACTOR, target)
      game.level.map(target.x, target.y, Map.ACTOR, self)
      self.x, self.y, target.x, target.y = target.x, target.y, self.x, self.y
      
      game:playSoundNear(self, "talents/teleport")
      return true
   end,
   info = function(self, t)
      return ([[Instantly switches places with one of your summons.]])
   end,
}

newTalent{
	name = "Planetary Convergence", short_name = "WANDER_CYCLE_BOOST",
	type = {"celestial/terrestrial_unity", 3},
	require = spells_req3,
	points = 5,
	no_energy = true,
	negative = 5,
	cooldown = 10,
	getDuration = function(self, t) return 3 end,
	getCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 2.6)) end,
	getExtension = function(self, t) return math.floor(self:combatTalentLimit(t, 6, 1, 2.8)) end,
	on_pre_use = function(self, t, silent)
		if not self:hasEffect(self.EFF_WANDER_KOLAL)
			or not self:hasEffect(self.EFF_WANDER_LUXAM)
			or not self:hasEffect(self.EFF_WANDER_PONX)
		then
			if not silent then game.logPlayer(self, "You require all three planetary charges.") end
			return false
		end
		return true
	end,
	action = function(self, t)
		local chargeFlame = self:hasEffect(self.EFF_WANDER_KOLAL)
		local chargeCold = self:hasEffect(self.EFF_WANDER_LUXAM)
		local chargeWind = self:hasEffect(self.EFF_WANDER_PONX)
		local ultimate = false
		if chargeFlame.stacks >= 5
			and chargeCold.stacks >= 5
			and chargeWind.stacks >= 5
		then
			ultimate = true
		end
		
		self:setEffect(self.EFF_WANDER_UNITY_CONVERGENCE, t.getDuration(self, t), {count=t.getCount(self, t), extend=t.getExtension(self, t), ultimate=ultimate})
		
		self:removeEffect(self.EFF_WANDER_KOLAL)
		self:removeEffect(self.EFF_WANDER_LUXAM)
		self:removeEffect(self.EFF_WANDER_PONX)
	end,
	
	info = function(self, t)
		return ([[When the worlds align, great power flows through the void.  Consume your planetary charges to make your next %d summons (within %d turns) call a Greater Elemental, which has an additional talent and lasts for %d additional turns.
Greater Gwelgoroth: Shocks and dazes enemies
Greater Shivgoroth: Freezes enemies in place
Greater Faeros: Launches bolts of fire when it attacks

If you have at least 5 of each charge, you will call an Ultimate Elemental, which have another additional talent.
Ultimate Gwelgoroth: Forms hurricanes
Ultimate Shivgoroth: Surrounded by an ice storm
Ultimate Faeros: Continually launches fire at nearby enemies]]):format(t.getCount(self, t), t.getDuration(self, t), t.getExtension(self, t))
	end,
}

newTalent{
	name = "Swift Arrival", short_name = "WANDER_GRAND_ARRIVAL",
	type = {"celestial/terrestrial_unity", 4},
	require = spells_req4,
	points = 5,
	mode = "passive",
	getSummonsPerTurn = function(self, t) return 1 + self:getTalentLevelRaw(t) end,
	info = function(self, t)
		return ([[Perfect your summoning techniques, increasing the speed of your summons.
Each rank greatly improves the casting speed of your summons, allowing you to summon %d elementals in one turn.
The bonuses are reflected in the description of each summon spell.]]):format(t.getSummonsPerTurn(self, t))
	end,
}
