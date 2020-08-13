knowRessource = Talents.main_env.knowRessource

uberTalent = function(t)
   t.type = {"uber/willpower", 1}
   t.uber = true
   t.require = t.require or {}
   t.require.stat = t.require.stat or {}
   t.require.level = 25
   t.require.stat.wil = 25
   newTalent(t)
end

uberTalent{
   name = "Fallen", short_name = "REK_PALADIN_FALLEN_PRODIGY", image="talents/fln_templar_splatter_sigils.png",
   require = {
      birth_descriptors={{"subclass", "Sun Paladin"}},
      special={desc="Unlocked the Fallen evolution", fct=function(self) return profile.mod.allow_build.rek_paladin_fallen end},
      stat = {mag=25},
   },
   is_class_evolution = "Sun Paladin",
   cant_steal = true,
   mode = "passive",
   no_npc_use = true,

   unlearnTalents = function(self, t, cats)
      local tids = {}
      local types = {}
      for id, lvl in pairs(self.talents) do
         local t = self.talents_def[id]
         if t.type[1] and cats[t.type[1]] ~= nil then
            types[t.type[1]] = true
            tids[id] = lvl
         end
      end
      local unlearnt = 0
      for id, lvl in pairs(tids) do self:unlearnTalent(id, lvl, nil, {no_unlearn=true}) unlearnt = unlearnt + lvl end
      --for tt, _ in pairs(types) do self.talents_types[tt] = nil end
      self.unused_talents = self.unused_talents + unlearnt

      for cat, v in pairs(cats) do
         self.talents_types[cat] = nil
      end
   end,

   learnAndMaster = function(self, cat, unlocked, mastery)
      self:learnTalentType(cat, unlocked)
      self:setTalentTypeMastery(cat, mastery)
   end,
   
   fall = function(self, t)
      --self.descriptor.subclass = "Fallen"
      t.learnAndMaster(self, "cursed/bloodstained", true, 1.3)
      t.learnAndMaster(self, "celestial/darkside", true, 1.3)

      t.learnAndMaster(self, "cursed/gloom", self:knowTalentType("celestial/radiance"), 1.3)

      t.learnAndMaster(self, "cursed/crimson-templar", self:knowTalentType("celestial/guardian"), 1.3)
      t.learnAndMaster(self, "celestial/black-sun", self:knowTalentType("celestial/crusader"), 1.3)

      t.learnAndMaster(self, "cursed/self-hatred", true, 1.3)
      t.learnAndMaster(self, "celestial/dirge", true, 1.3)
      
      local removes = {
         ["celestial/crusader"] = true,
         ["celestial/guardian"] = true,
         ["celestial/radiance"] = true,
         ["technique/2hweapon-assault"] = true,
         ["technique/shield-offense"] = true,
      }
      t.unlearnTalents(self, t, removes)

      self:learnTalent(self.T_FLN_DIRGE_ACOLYTE, true, 1)
      self:learnTalent(self.T_FLN_SELFHATE_HARM, true, 1)
      
      self:incHate(100)
   end,
   on_learn = function(self, t)
      t.fall(self, t)
   end,
   info = function(self, t)
      return ([[The code of the Sun Paladins can be a heavy burden.  Wouldn't you like to let go?
To give in to your hate?

Any offensive combat techniques or unlockable Celestial talent trees you know will be exchanged for cursed versions, allowing you to cut a bloody trail through enemies, turning your radiance to gloom, and more.
You also gain new generic trees: the Fallen's defensive Dirges and Self-Destructive combat style.]]):format()
end,
}
