knowRessource = Talents.main_env.knowRessource

uberTalent = function(t)
   t.type = {"uber/cunning", 1}
   t.uber = true
   t.require = t.require or {}
   t.require.stat = t.require.stat or {}
   t.require.level = 25
   t.require.stat.cun = 50
   newTalent(t)
end

uberTalent{
   name = "Hollow", short_name = "REK_DOOMED_SHADOW_PRODIGY",
   require = {
      birth_descriptors={{"subclass", "Doomed"}},
      special={
         desc="10 points in Cursed/Shadows talents",
         fct=function(self)
            return self:getTalentLevelRaw(self.T_CALL_SHADOWS) + self:getTalentLevelRaw(self.T_SHADOW_WARRIORS) + self:getTalentLevelRaw(self.T_SHADOW_MAGES) + self:getTalentLevelRaw(self.T_FOCUS_SHADOWS) >= 10
         end
      }
   },
   is_class_evolution = "Doomed",
   cant_steal = true,
   mode = "passive",
   no_npc_use = true,

   unlearnTalents = function(self, t)
      local tids = {}
      local types = {}
      for id, lvl in pairs(self.talents) do
         local t = self.talents_def[id]
         if t.type[1] and (t.type[1]:find("^cursed/punishments") or t.type[1]:find("^cursed/force-of-will")) then
            types[t.type[1]] = true
            tids[id] = lvl
         end
      end
      local unlearnt = 0
      for id, lvl in pairs(tids) do self:unlearnTalent(id, lvl, nil, {no_unlearn=true}) unlearnt = unlearnt + lvl end
      for tt, _ in pairs(types) do self.talents_types[tt] = nil end
      self.unused_talents = self.unused_talents + unlearnt
   end,
   
   becomeHollow = function(self, t)
      self.descriptor.race = "Shadow"
      --self.descriptor.subrace = "Shadow"
      self.blood_color = colors.GREY

      --hate_regen = 1,
      avoid_traps = 1,
      self:attr("size_category", -1)
      self:attr("undead", 1)
      self:attr("true_undead", 1)

      self:attr("stone_immune", 1)
      self:attr("fear_immune", 1)
      self:attr("teleport_immune", 1)    
      self:attr("blind_immune", 1)
      
      --confusion, disease, poison, stun,
--      self:attr("confusion_immune", 1)
--      self:attr("disease_immune", 1)
--      self:attr("poison_immune", 1)
--      self:attr("stun_immune", 1)
      
      self:attr("no_breath", 1)

      t.unlearnTalents(self, t)
      
      --life drop
      self.life_rating = self.life_rating - 5
      self.max_life = self.max_life - 5 * (1.1 * (self.level-1) + ((self.level-1) * (self.level - 2) / 80))

      self:learnTalentType("undead/shadow-destruction", true)
      self:learnTalentType("undead/shadow-magic", true)
      self:setTalentTypeMastery("undead/shadow-magic", 1.3)
      self:setTalentTypeMastery(tt"undead/shadow-destruction", 1.3)
      
      if self:attr("blood_life") then
         self.blood_life = nil
         game.log("#GREY#As you turn into a powerful shade you feel yourself violently rejecting the Blood of Life.")
      end
      
      game.level.map:particleEmitter(self.x, self.y, 1, "demon_teleport")
      if not self.shader then
         self.shader = "rek_seething_darkness"
         self.shader_args = { a_min = 0, a_max = 0.8, base = 0.1 }
         self:removeAllMOs()
         game.level.map:updateMap(self.x, self.y)
      end
   end,
   callbackOnRest = function(self, t, status)
      if not self.shader then
         self.shader = "rek_seething_darkness"
         self.shader_args = { a_min = 0, a_max = 0.8, base = 0.1 }
         self:removeAllMOs()
         game.level.map:updateMap(self.x, self.y)
      end
   end,
   on_levelup_close = function(self, t, lvl, old_lvl, lvl_raw, old_lvl_raw)
      t.becomeHollow(self, t)
   end,
   info = function(self, t)
      return ([[You exist in eternal pursuit of something you can never regain, your very being scattered across the shadows you cast into the world.  The hatred has filled you so deeply that there's nothing left of you but another shadow.  You transcend mortality as an embodiment of hate, an entity of pure, living darkness.

You can no longer use infusions, you shrink by one size category, and your maximum life will be greatly reduced.  You lose access to Force of Will and Punishments, and all talent points you spent there will be refunded.

In exchange, you can use shadow magic for elemental attacks, healing, and teleportation. You can be anywhere your shadows are, and will only die if all your shadows are killed. You cannot trigger pressure traps, and are immune to petrification, fear, hostile teleports, blindness, and suffocation.
]]):format()
end,
}
