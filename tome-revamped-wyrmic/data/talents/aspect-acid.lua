local Object = require "mod.class.Object"

function getAspectResists(self, t)
   return self:combatTalentScale(t, 2, 25)
end

newTalent{
   name = "Corrosive Sprays", short_name = "REK_WYRMIC_ACID",
   type = {"wild-gift/wyrm-acid", 1},
   require = {
      stat = { wil=function(level) return 10 + (level-1) * 4 end },
      level = function(level) return 0 + (level-1) * 3 end,
      special =
	 {
         desc="You can learn a new aspect every 6 levels",
         fct=function(self)
            return self:knowTalent(self.T_REK_WYRMIC_ACID) or self.level >= numAspectsKnown(self)*6
	    end
	 },
   },
   points = 5,
   on_learn = function(self, t)
      if self.rek_wyrmic_dragon_damage == nil then
	 self.rek_wyrmic_dragon_damage = {
	    name="Acid",
	    nameStatus="Disarmed",
	    nameDrake=(DamageType:get(DamageType.ACID).text_color or "").."Acid Drake#LAST#",
	    damtype=DamageType.ACID,
	    status=DamageType.REK_WYRMIC_ACID,
	    talent=self.T_REK_WYRMIC_ACID
	 }
      end
      onLearnAspect(self, t)
   end,
   on_unlearn = function(self, t) onUnLearnAspect(self) end,
      
   mode = "passive",
   -- Get resists for use in Prismatic Blood
   getResists = getAspectResists,
   -- For elemental Spray
   getCorrodeDur = function(self, t) return math.floor(self:combatTalentScale(t, 3.3, 5.8)) end,
   getAtk = function(self, t) return self:combatMindpower()+self:combatTalentMindDamage(t, 0, 1) end,
   passives = function(self, t, p)
      local resist = t.getResists(self, t)
      self:talentTemporaryValue(p, "resists", {[DamageType.ACID] = resist})
   end,
   info = function(self, t)
      local resist = t.getResists(self, t)
      local corrosion = t.getAtk(self, t)
      return ([[You can take on the power of Acid Wyrms, giving you %d%% acid resistance. Whenever you use Elemental Spray it will corrode affected enemies, reducing their accuracy and power by %d (#SLATE#Mindpower vs. Physical#LAST#), based on your mindpower.

Acid damage can inflict Disarm (#SLATE#Mindpower vs. Physical#LAST#).
]]):format(resist, corrosion)
   end,
}

newTalent{
   name = "Softening Aura", short_name = "REK_WYRMIC_ACID_AURA",
   type = {"wild-gift/wyrm-acid", 2},
   require = {
      stat = { wil=function(level) return 22 + (level-1) * 2 end },
      level = function(level) return 10 + (level-1) end,
      special =
	 {
	    desc="Advanced aspect talents learnable",
	    fct=function(self) 
	       return self:knowTalent(self.T_REK_WYRMIC_ACID_AURA)
		  or self.unused_talents_types >= 1
	    end
	 },
   },
   points = 5,
   equilibrium = 5,
   cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 10, 40, 15)) end,
   range = 1,
   requires_target = true,
   no_energy = true,
   tactical = { DISABLE = 2 },
   radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 60) end,
   getDuration = function(self, t) return math.floor(self:combatScale(self:combatMindpower(0.04) + self:getTalentLevel(t)/2, 6, 0, 7.67, 5.67)) end,
   target = function(self, t)
      return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
   end,
   on_learn = function(self, t) onLearnHigherAbility(self, t) end,
   on_unlearn = function(self, t) onUnLearnHigherAbility(self, t) end,
   action = function(self, t)
      local damage = self:mindCrit(t.getDamage(self, t))
      local duration = t.getDuration(self, t)
      local actor = self
      local radius = self:getTalentRadius(t)
      -- Add a lasting map effect
      game.level.map:addEffect(self,
			       self.x, self.y, duration,
			       DamageType.REK_WYRMIC_ACID_SLOW, damage,
			       radius,
			       5, nil,
			       engine.MapEffect.new{color_br=80, color_bg=255, color_bb=25, effect_shader="shader_images/magic_effect.png"},
			       function(e)
				  e.x = e.src.x
				  e.y = e.src.y
				  return true
			       end,
			       false
      )
      game:playSoundNear(self, "talents/cloud")
      return true
   end,
   info = function(self, t)
      local radius = self:getTalentRadius(t)
      local duration = t.getDuration(self, t)
      local slow = t.getDamage(self, t)
      local notice = (self:getTalentLevelRaw(t) == 1000 or (self:getTalentLevelRaw(t) < 2)) and [[


#YELLOW#Learning the advanced acid talents costs a category point.#LAST#]] or ""
      return ([[Dissolve the ground around you in radius %d for %d turns, causing it to slow the movement speed of enemies within by %d%% (#SLATE#Mindpower vs. Physical#LAST#).  The aura moves with you.%s]]):format(radius, duration, slow, notice)
   end,
}


newTalent{
   name = "Dissolution", short_name = "REK_WYRMIC_ACID_DISSOLVE",
   type = {"wild-gift/wyrm-acid", 3},
   require = gifts_req_high2,
   points = 5,
   cooldown = 15,
   tactical = { DISABLE = 2, ATTACK = {ACID = 1} },
   range = 7,
   equilibrium = 10,
   getDamage = function(self, t) return self:combatTalentMindDamage(t, 10, 120) end,
   getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
   target = function(self, t)
      return {type="hit", range=self:getTalentRange(t), talent=t}
   end,
   requires_target = true,
   direct_hit = true,
   action = function(self, t)
      local tg = self:getTalentTarget(t)
      local x, y, target = self:getTarget(tg)
      local _ _, x, y = self:canProject(tg, x, y)
      local target = game.level.map(x, y, Map.ACTOR)
      if not x or not y or not target then return nil end
      
      target:setEffect(target.EFF_REK_WYRMIC_DISSOLVE, t.getDuration(self, t), { power=t.getDamage(self, t), apply_power=self:combatMindpower(), src=self })

      game:playSoundNear(self, "talents/rek_wyrmic_dissolution")
      
      return true
   end,
   info = function(self, t)
      local damage = t.getDamage(self, t)
      local duration = t.getDuration(self, t)
      return ([[Launch a clinging glob of acid at an enemy.  Each turn for the next %d turns, the target will take %d acid damage and may (#SLATE#Mindpower vs. Mental#LAST#) have one of their sustained talents deactivated.

Mindpower: Improves damage]]):format(duration, damDesc(self, DamageType.ACID, damage))
   end,
   }

newTalent{
	name = "Scour Clean", short_name = "REK_WYRMIC_ACID_SCOUR",
	type = {"wild-gift/wyrm-acid", 4},
	require = gifts_req_high3,
	points = 5,
	mode = "passive",
	getNumber = function(self, t) return 1 + math.floor(self:combatTalentScale(t, 1, 5)) end,
	callbackOnActBase = function(self, t)
		local max_nb = t.getNumber(self, t)
		local dur = 1
		local effs = {}
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" and e.type ~= "other" and not e.subtype["cross tier"] then
				effs[#effs+1] = eff_id
			end
		end
		
		for i = 1, max_nb do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)
			
			local e2 = self.tmp[eff]
			local odur = e2.dur
			e2.dur = e2.dur - 1
			if e2.dur <= 0 then self:removeEffect(eff) end
		end
	end,
	
	info = function(self, t)
		local nb = t.getNumber(self, t)
		return ([[Detrimental effects on you expire twice as fast.
This affects up to %d effects each turn.
This will not affect cross-tier effects (Off-Balance, Brainlock, Spellshock)]]):format(nb)
	end,
}
