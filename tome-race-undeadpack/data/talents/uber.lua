knowRessource = Talents.main_env.knowRessource

uberTalent = function(t)
   t.type = {"uber/magic", 1}
   t.uber = true
   t.require = t.require or {}
   t.require.stat = t.require.stat or {}
   t.require.level = 25
   t.require.stat.mag = 40
   newTalent(t)
end

uberTalent{
   name = "Dreadmaster", short_name = "REK_DREAD_PRODIGY", image  = "talents/rek_dread_stealth.png",
   require = {
      special={
         desc="Is a standard undead creature (not a Lich or Exarch)",
         fct=function(self)
            return self:attr("undead") and (self:attr("true_undead") or self:knowTalent(self.T_RAKSHOR_CUNNING)) and not self:attr("greater_undead")
         end
      },
      stat = {wil=25, mag=25},
   },
   is_race_evolution = function(self, t)
      if self:knowTalent(t.id) then return true end
      return self:attr("undead") and (self:attr("true_undead") or self:knowTalent(self.T_RAKSHOR_CUNNING)) and not self:attr("greater_undead")
   end,
   cant_steal = true,
   is_spell = true,
   is_necromancy = true,
   mode = "passive",
   no_npc_use = true,
   becomeDread = function(self, t)
      self.descriptor.race = "Undead"
      self.descriptor.subrace = "Dread"
      self.blood_color = colors.GREY
      self:attr("poison_immune", 1)
      self:attr("disease_immune", 1)
      self:attr("confusion_immune", 1)
      self:attr("cut_immune", 1)
      self:attr("fear_immune", 1)
      self:attr("no_breath", 1)
      
      self:attr("undead", 1)
      self:attr("true_undead", 1)

      self:attr("forbid_nature", 1)
      self.inscription_forbids = self.inscription_forbids or {}
      self.inscription_forbids["inscriptions/infusions"] = true
      
      self:learnTalentType("undead/dreadlord", true)
      self:learnTalentType("undead/dreadmaster", true)
      self:learnTalent(self.T_REK_DREAD_STEALTH, true, 1)
      self:learnTalent(self.T_REK_DREAD_SUMMON_DREAD, true, 1)

      self:forceUseTalent(self.T_REK_DREAD_STEALTH, {ignore_energy=true})
      
      if self:attr("blood_life") then
         self.blood_life = nil
         game.log("#GREY#As you turn into a powerful undead you feel yourself violently rejecting the Blood of Life.")
      end
      
      game.level.map:particleEmitter(self.x, self.y, 1, "demon_teleport")
   end,
   on_learn = function(self, t)
      self:attr("greater_undead", 1)
      t.becomeDread(self, t)
   end,
   on_unlearn = function(self, t)
      self:attr("greater_undead", -1)
   end,
   info = function(self, t)
      return ([[Embrace death and destruction to become a creature of pure spirit, a mighty Dreadmaster!
		As a dreadmaster, you will be immune to poisons, diseases, fear, cuts, confusion, and the need to breathe.
		Dreadmasters gain a new racial tree with the following talents:
 - Walking Blasphemy: Creatures of spirit, dreads are continually stealthed, and dangerous to even look at.
 - Corrupting Touch: Your mere touch steals away strength and skill, removing temporary bonuses and sustained talents.
 - Black Gate: Disappear into the darkness or pop up behind your enemies.
 - Phantasmal Step: Pass through walls after using your abilities.

		They also gain a class talent tree that allows them to summon lesser Dreads.]]):tformat()
end,
}
