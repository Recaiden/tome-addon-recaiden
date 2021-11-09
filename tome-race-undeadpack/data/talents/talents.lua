local ActorTalents = require "engine.interface.ActorTalents"
local Stats = require "engine.interface.ActorStats"
local Map = require "engine.Map"

damDesc = function(self, type, dam)
   -- Increases damage
   if self.inc_damage then
      local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
      dam = dam + (dam * inc / 100)
   end
   return dam
end

undeads_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
undeads_req2 = {
	level = function(level) return 8 + (level-1)  end,
}
undeads_req3 = {
	level = function(level) return 16 + (level-1)  end,
}
undeads_req4 = {
	level = function(level) return 24 + (level-1)  end,
}

mummy_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
mummy_req2 = {
	level = function(level) return 4 + (level-1)  end,
}
mummy_req3 = {
	level = function(level) return 8 + (level-1)  end,
}
mummy_req4 = {
	level = function(level) return 12 + (level-1)  end,
}
mummy_req5 = {
   level = function(level) return 16 + (level-1)  end,
   special={
      desc="Know two Canopic Jar talents",
      fct=function(self)
         return (self:knowTalent(self.T_JAR_STOMACH) and 1 or 0) + (self:knowTalent(self.T_JAR_INTESTINE) and 1 or 0) + (self:knowTalent(self.T_JAR_LIVER) and 1 or 0) + (self:knowTalent(self.T_JAR_LUNG) and 1 or 0) >= 2
      end}
}

high_undeads_req1 = { level = function(level) return 25 + (level-1)  end }
high_undeads_req2 = { level = function(level) return 28 + (level-1)  end }
high_undeads_req3 = { level = function(level) return 30 + (level-1)  end }
high_undeads_req4 = { level = function(level) return 32 + (level-1)  end }

dreads_req1 = { level = function(level) return 20 + (level-1)  end }
dreads_req2 = { level = function(level) return 24 + (level-1)  end }
dreads_req3 = { level = function(level) return 28 + (level-1)  end }
dreads_req4 = { level = function(level) return 32 + (level-1)  end }

if not Talents.talents_types_def["undead/banshee"] then
   newTalentType{ type="undead/banshee", name = "banshee", is_spell=true, generic = true, description = "The various racial bonuses an undead banshee character can have."}
   load("/data-race-undeadpack/talents/banshee.lua")
end

if not Talents.talents_types_def["undead/wight"] then
   newTalentType{ type="undead/wight", name = "wight", is_spell=true, generic = true, description = "The various racial bonuses an undead wight character can have."}
   load("/data-race-undeadpack/talents/wight.lua")
end

if not Talents.talents_types_def["undead/mummy"] then
   newTalentType{ type="undead/mummy", name = "mummy", is_spell=true, generic = true, description = "The various racial bonuses a mummified undead character can have."}
newTalentType{ type="undead/mummified", name = "mummified", is_spell=true, generic = true, description = "The special bonuses owed to preserved body parts."}
   load("/data-race-undeadpack/talents/mummy.lua")
end

if Talents.talents_def["T_RAKSHOR_CUNNING"] then
	local Dialog = require "engine.ui.Dialog"
	local base_cbodb = Talents.talents_def["T_RAKSHOR_CUNNING"].callbackOnDeathbox

	local function make_undead(self, choice, dialog)
			self.rakshor_resurrected = true
			dialog:cleanActor(self)
			dialog:resurrectBasic(self, "rakshor_cunning")
			dialog:restoreResources(self)

			self:attr("undead", 1)
			self:attr("true_undead", 1)
			self.inscription_forbids = self.inscription_forbids or {}
			self.inscription_forbids["inscriptions/infusions"] = true

			self.descriptor.race = "Undead"
			if choice == "banshee" then
				self.descriptor.subrace = "Banshee"
				if not self.has_custom_tile then
					self.moddable_tile = "human_#sex#"
					self.moddable_tile_base = "base_banshee_01.png"
					self.moddable_tile_ornament = nil
					self.attachement_spots = "race_human"
				end
				self.life_rating = 9
				self:attr("silence_immune", 1)
				self:attr("cut_immune", 1)
				self:attr("fear_immune", 1)

				self:learnTalentType("undead/banshee", true)
				self:setTalentTypeMastery("undead/banshee", 1.1)
				self:learnTalent(self.T_REK_BANSHEE_WAIL, true, 2)
				self:learnTalent(self.T_REK_BANSHEE_RESIST, true, 2)
				self:learnTalent(self.T_REK_BANSHEE_CURSE, true, 2)
				self:learnTalent(self.T_REK_BANSHEE_GHOST, true, 2)
			else
				self.descriptor.subrace = "Wight"
				if not self.has_custom_tile then
					self.moddable_tile = "human_#sex#"
					self.moddable_tile_base = "wight_hollow_blue.png"
					self.moddable_tile_ornament = nil
					self.attachement_spots = "race_human"
				end
				self.life_rating = 11

				self:attr("poison_immune", 0.8)
				self:attr("cut_immune", 1)
				self:attr("fear_immune", 1)
				self:attr("no_breath", 1)

				self:learnTalentType("undead/wight", true)
				self:setTalentTypeMastery("undead/wight", 1.1)
				self:learnTalent(self.T_REK_WIGHT_FURY, true, 2)
				self:learnTalent(self.T_REK_WIGHT_DRAIN, true, 2)
				self:learnTalent(self.T_REK_WIGHT_DODGE, true, 2)
				self:learnTalent(self.T_REK_WIGHT_GHOST_VISION, true, 2)
			end

			game.level.map:particleEmitter(self.x, self.y, 1, "demon_teleport")

			self:updateModdableTile()
			self:check("on_resurrect", "rakshor_cunning")
			self:triggerHook{"Actor:resurrect", reason="rakshor_cunning"}

			Dialog:yesnoLongPopup(_t"Rak'Shor's Cunning", _t"#GREY#Applying you cunning plans, you escape death by turning to undeath in an instant!\n\n#{italic}#You may now choose to customize your undead appearance, this can not be changed afterwards.", 600, function(ret) if ret then
				require("mod.dialogs.Birther"):showCosmeticCustomizer(self, _t"Cosmetic Options")
			end end, _t"Customize Appearance", _t"Use Default", true)
		end
	
	Talents.talents_def["T_RAKSHOR_CUNNING"].callbackOnDeathbox = function(self, t, dialog, list)
		list[#list+1] = {name=_t"Rak'Shor's Cunning (Wight)", action=function() make_undead(self, "wight", dialog) end, force_choice=true}
		list[#list+1] = {name=_t"Rak'Shor's Cunning (Banshee)", action=function() make_undead(self, "banshee", dialog) end, force_choice=true}
		base_cbodb(self, t, dialog, list)
	end

	local base_info = Talents.talents_def["T_RAKSHOR_CUNNING"].info

	Talents.talents_def["T_RAKSHOR_CUNNING"].info = function(self, t)
		return ([[%s

You can also choose to become a Banshee or Wight.]]):tformat(base_info(self, t))
	end
	
end

if not Talents.talents_types_def["undead/dreadlord"] then
   newTalentType{ type="undead/dreadlord", name = "dreadlord", is_spell=true, generic = true, description = "The various racial bonuses a dark spirit can have."}
   newTalentType{ type="undead/dreadmaster", name = "dreadmaster", is_spell=true, description = "Summon undead minions of pure darkness to harass your foes."}
   load("/data-race-undeadpack/talents/dreadlord.lua")
   load("/data-race-undeadpack/talents/uber.lua")
end
