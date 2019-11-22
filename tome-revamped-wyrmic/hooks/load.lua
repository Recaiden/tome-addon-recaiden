local class = require"engine.class"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorInventory = require "engine.interface.ActorInventory"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"
local Zone = require "engine.Zone"
local Map = require "engine.Map"
local Game = require "engine.Game"
local Particles = require "engine.Particles"

class:bindHook("ToME:load", function(self, data)
  ActorInventory:defineInventory("REK_WYRMIC_GEM", "Socketed Gems", true, "Gems worn in/on the body, providing their worn bonuses without granting their latent damage type", nil, {equipdoll_back="ui/equipdoll/gem_inv.png", stack_limit = 1})
  Talents:loadDefinition('/data-revamped-wyrmic/talents/gifts/wild-gift.lua')
  ActorTemporaryEffects:loadDefinition('/data-revamped-wyrmic/effects.lua')
  Birther:loadDefinition("/data-revamped-wyrmic/birth/classes/wilder.lua")
  DamageType:loadDefinition("/data-revamped-wyrmic/damage_types.lua")
  modifyWyrmicTrees()
end)

--class:bindHook("Entity:loadList", function(self, data)
--		  if data.file == "/data/general/objects/world-artifacts.lua" then
--		     self:loadList("/data-revamped-wyrmic/world-artifacts.lua", data.no_default, data.res, data.mod, data.loaded)
--		  end
--end)

function modifyWyrmicTrees()
   damDesc = Talents.damDesc
   
   if Talents.talents_def.T_TENTACLED_WINGS then
      Talents.talents_def.T_TENTACLED_WINGS.on_learn = function(self, t)
         self:learnTalent(self.T_REK_WYRMIC_COLOR_PRIMARY, true, nil)
         if self.rek_wyrmic_dragon_damage == nil then
            self.rek_wyrmic_dragon_damage = {
               name="Blight",
               nameDrake=DamageType:get(DamageType.BLIGHT).text_color.."Scourge Drake#LAST#",
               nameStatus="Diseased",
               damtype=DamageType.BLIGHT,
               status=DamageType.REK_CORRUPTED_BLOOD,
               talent=self.T_REK_TENTACLED_WINGS
            }
         end
      end
      
      Talents.talents_def.T_TENTACLED_WINGS.on_unlearn = function(self, t)
         self:unlearnTalent(self.T_REK_WYRMIC_COLOR_PRIMARY)
      end
      
      Talents.talents_def.T_TENTACLED_WINGS.getResists = function(self, t) return self:combatTalentScale(t, 2, 25) end
      
      Talents.talents_def.T_TENTACLED_WINGS.getDiseaseStrength = function(self, t)
         return self:combatScale(self:combatSpellpower(), 10, 10, 20, 100)
      end

      Talents.talents_def.T_TENTACLED_WINGS.action = function(self, t)
         local tg = self:getTalentTarget(t)
         local x, y = self:getTarget(tg)
         if not x or not y then return nil end
         
         local weapondam = t.getDamage(self, t)
         self:project(tg, x, y, function(px, py)
                         local act = game.level.map(px, py, Map.ACTOR)
                         if act and self:reactionToward(act) < 0 then
                            local shield, shield_combat = self:hasShield()
                            local weapon = self:hasMHWeapon() and self:hasMHWeapon().combat or self.combat
                            local hit = false
                            if not shield then
                               hit = self:attackTarget(act, DamageType.BLIGHT, weapondam, true)
                            else
                               hit = self:attackTargetWith(act, weapon, DamageType.BLIGHT, weapondam)
                               if self:attackTargetWith(act, shield_combat, DamageType.BLIGHT, weapondam)
                                  or hit
                               then hit = true
                               end
                            end
                            if hit then act:pull(self.x, self.y, self:getTalentRange(t)) end
                            self:addParticles(Particles.new("tentacle_pull", 1, {range=core.fov.distance(self.x, self.y, px, py), dir=math.deg(math.atan2(py-self.y, px-self.x)+math.pi/2)}))
                         end
                                end)
         
         if core.shader.active(4) then
            local bx, by = self:attachementSpot("back", true)
            self:addParticles(Particles.new("shader_wings", 1, {img="sickwings", life=18, x=bx, y=by, fade=-0.006, deploy_speed=14}))
         end
         
         return true
      end
      
      Talents.talents_def.T_TENTACLED_WINGS.info = function(self, t)
         return ([[You can take on the power of the otherworldly Scourge using Prismatic Blood.  You will gain %d%% blight resistance and can inflict Scourge damage using your draconic talents.

Activate this talent to project tentacles in a cone of radius %d in front of you.
Any foes caught inside are grappled by the tentacles, suffering %d%% weapon damage as blight and being pulled towards you (#SLATE#no save#LAST#). This will also attack with your shield, if you have one equipped.

Scourge is blight that can inflict a virulent disease (#SLATE#Spellpower vs. Spell#LAST#), reducing one of strength, dexterity, or constitution by %d.  The strength of the disease depends on your Spellpower.]]):
         format(t.getResists(self, t), self:getTalentRange(t), damDesc(self, DamageType.BLIGHT, t.getDamage(self, t) * 100), t.getDiseaseStrength(self, t))
      end
   end

   if Talents.talents_def.T_RAZE then
      Talents.talents_def.T_RAZE.getResists = function(self, t) return self:combatTalentScale(t, 2, 25) end

      Talents.talents_def.T_RAZE.on_learn = function(self, t)
         self:learnTalent(self.T_REK_WYRMIC_COLOR_PRIMARY)
      end

      Talents.talents_def.T_RAZE.on_unlearn = function(self, t)
         self:unlearnTalent(self.T_REK_WYRMIC_COLOR_PRIMARY)
      end
      Talents.talents_def.T_RAZE.soulBonus = function(self, t) return 1 end
      Talents.talents_def.T_RAZE.info = function(self, t)
         local damage = t.getDamage(self, t)
         return ([[You revel in death and can take on the power of the Eternal Wyrm using Prismatic Blood, granting you %d%% darkness resistance and the ability to Doom enemies using your other draconic talents.

Whenever you inflict damage to a target, you deal an additional %0.2f darkness damage (up to 15 times per turn).
The damage will scale with the higher of your spell or mind power.

You will gain a soul whenever you score a kill or hit with Devour.

Doom is darkness damage that can reduce enemy healing by up to 75%%.
]]):
         format(t.getResists(self, t), damDesc(self, DamageType.DARKNESS, damage), t.soulBonus(self,t))
      end

      Talents.talents_def.T_NECROTIC_BREATH.name = "Ureslak's Curse"
      Talents.talents_def.T_NECROTIC_BREATH.radius = function(self, t) return math.floor(self:combatTalentScale(t, 2.3, 3.7)) end
      Talents.talents_def.T_NECROTIC_BREATH.range = function(self, t) return 7 end
      Talents.talents_def.T_NECROTIC_BREATH.direct_hit = false
      Talents.talents_def.T_NECROTIC_BREATH.target = function(self, t)
         return {type="ball", nolock=true, pass_terrain=false, friendly_fire=false, nowarning=true, range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
      end
      Talents.talents_def.T_NECROTIC_BREATH.getDamage = function(self, t)
         return self:combatTalentStatDamage(t, "mag", 30, 550)
      end
      Talents.talents_def.T_NECROTIC_BREATH.getDuration = function(self, t)
         return self:combatTalentScale(t, 3, 5)
      end
      Talents.talents_def.T_NECROTIC_BREATH.action = function(self, t)
         local tg = self:getTalentTarget(t)
         local x, y = self:getTarget(tg)
         if not x or not y then return nil end
         self:project(tg, x, y, DamageType.CIRCLE_DEATH, {dam=self:spellCrit(t.getDamage(self, t))/4,dur=t.getDuration(self, t)})
         game.level.map:particleEmitter(x, y, tg.radius, "circle", {zdepth=6, oversize=1, a=130, appear=8, limit_life=24, speed=5, img="necromantic_circle", radius=tg.radius})
         
         if core.shader.active(4) then
            local bx, by = self:attachementSpot("back", true)
            self:addParticles(Particles.new("shader_wings", 1, {img="darkwings", life=18, x=bx, y=by, fade=-0.006, deploy_speed=14}))
         end
         game:playSoundNear(self, "talents/fire")
         return true
      end
      Talents.talents_def.T_NECROTIC_BREATH.info  = function(self, t)
         return ([[You conjure a wave of deathly miasma in a circle of radius %d. Any target caught in the area will take %0.2f darkness damage over %d turns and receive either a bane of confusion or a bane of blindness for the duration.
Magic: Increases damage]]):format(self:getTalentRadius(t), damDesc(self, DamageType.DARKNESS, t.getDamage(self, t)), t.getDuration(self, t))
      end
   end
end

class:bindHook("Entity:loadList",
	       function(self, data)
		  for _,obj in pairs(data.res) do
		     if type(obj) == "table" then
			if obj.type == "gem" then
			   obj.offslot = "REK_WYRMIC_GEM"
			end
		     end
		  end
end)
