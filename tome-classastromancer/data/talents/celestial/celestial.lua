local ActorTalents = require "engine.interface.ActorTalents"

damDesc = function(self, type, dam)
	-- Increases damage
	if self.inc_damage then
		local inc = (self.inc_damage.all or 0) + (self.inc_damage[type] or 0)
		dam = dam + (dam * inc / 100)
	end
	return dam
end

-- Generic requires for spells based on talent level
spells_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
spells_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
spells_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
spells_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
spells_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
spells_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
spells_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
spells_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
spells_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
spells_req_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

function astromancerSummonSpeed(self, t)
   local speed = self:getSpeed('spell')
   if self:knowTalent(self.T_WANDER_GRAND_ARRIVAL) then
      speed = speed / (1 + self:getTalentLevelRaw(self.T_WANDER_GRAND_ARRIVAL) )
   end
   return speed
end


function checkMaxSummonStar(self, silent, div, check_attr)
	div = div or 1
	local nb = 0
	
	-- Count party members
	if game.party:hasMember(self) then
		for act, def in pairs(game.party.members) do
			if act.summoner and act.summoner == self and act.type == "elemental" and not act.ignore_summon_cap and (not check_attr or act:attr(check_attr)) then
				nb = nb + 1
			end
		end
	elseif game.level then
		for _, act in pairs(game.level.entities) do
			if act.summoner and act.summoner == self and act.type == "elemental" and not act.ignore_summon_cap and (not check_attr or act:attr(check_attr)) then
				nb = nb + 1
			end
		end
	end

	local max = 2 + util.bound(
		math.floor(self:combatStatScale("cun", 10^.5, 10)),
		1,
		math.max(1, math.floor(self:getCun() / 10))
														)
	max = math.ceil(max / div)
	if nb >= max then
		if not silent then
			game.logPlayer(self, "#PINK#You can manage a maximum of %d summons at any time. You need %d Cunning to increase your limit.", max, math.max((max-1)*10, (max-1)^2))
		end
		return true, nb, max
	else
		return false, nb, max
	end
end

function setupSummonStar(self, m, x, y, no_control)
   m.unused_stats = 0
   m.unused_talents = 0
   m.unused_generics = 0
   m.unused_talents_types = 0
   m.no_inventory_access = true
   m.no_points_on_levelup = true
   m.save_hotkeys = true
   m.ai_state = m.ai_state or {}
   m.ai_state.tactic_leash = 100
   -- Try to use stored AI talents to preserve tweaking over multiple summons
   m.ai_talents = self.stored_ai_talents and self.stored_ai_talents[m.name] or {}
   local main_weapon = self:getInven("MAINHAND") and self:getInven("MAINHAND")[1]
   m:attr("combat_apr", self:combatAPR(main_weapon))
   m.inc_damage = table.clone(self.inc_damage, true)
   m.resists_pen = table.clone(self.resists_pen, true)
   m:attr("stun_immune", self:attr("stun_immune"))
   m:attr("blind_immune", self:attr("blind_immune"))
   m:attr("pin_immune", self:attr("pin_immune"))
   m:attr("confusion_immune", self:attr("confusion_immune"))
   m:attr("numbed", self:attr("numbed"))
   if game.party:hasMember(self) then
      local can_control = not no_control and self:knowTalent(self.T_SUMMON_CONTROL)
      
      m.remove_from_party_on_death = true
      game.party:addMember(m, {
			      control=can_control and "full" or "no",
			      type="summon",
			      title="Summon",
			      orders = {target=true, leash=true, anchor=true, talents=true},
			      on_control = function(self)
				 local summoner = self.summoner
				 self:setEffect(self.EFF_SUMMON_CONTROL, 1000, {incdur=summoner:callTalent(summoner.T_SUMMON_CONTROL, "lifetime"), res=summoner:callTalent(summoner.T_SUMMON_CONTROL, "DamReduc")})
				 self:hotkeyAutoTalents()
			      end,
			      on_uncontrol = function(self)
				 self:removeEffect(self.EFF_SUMMON_CONTROL)
			      end,
      })
   end
   m:resolve() m:resolve(nil, true)
   m:forceLevelup(self.level)
   game.zone:addEntity(game.level, m, "actor", x, y)
   game.level.map:particleEmitter(x, y, 1, "summon")
   
   -- Summons never flee
   m.ai_tactic = m.ai_tactic or {}
   m.ai_tactic.escape = 0
      
   self:attr("summoned_times", 1)
end

if not Talents.talents_types_def["celestial/ponx"] then
   newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/ponx", name = "Ponx", description = "Celestial spellcasting drawn from the whirling gas giant Ponx in the middle reaches of the solar system." }
   load("/data-classastromancer/talents/celestial/ponx.lua")
end

if not Talents.talents_types_def["celestial/luxam"] then
   newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/luxam", name = "Luxam", description = "Celestial spellcasting drawn from the icy world of Luxam in the dark depths of space." }
   load("/data-classastromancer/talents/celestial/luxam.lua")
end

if not Talents.talents_types_def["celestial/kolal"] then
   newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/kolal", name = "Kolal", description = "Celestial spellcasting drawn from Eyal's nearest neighbor, the fiery wasteland of Kolal." }
   load("/data-classastromancer/talents/celestial/kolal.lua")
end

if not Talents.talents_types_def["celestial/nekal"] then
   newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/nekal", name = "Nekal", description = "Celestial spellcasting drawn from the mysterious water-world of Nekal." }
   load("/data-classastromancer/talents/celestial/nekal.lua")
end

if not Talents.talents_types_def["celestial/unity"] then
   newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/terrestrial_unity", name = "Terrestrial Unity", description = "Celestial augmentations based on keeping the planets in harmonious balance." }
   load("/data-classastromancer/talents/celestial/unity.lua")
end

if not Talents.talents_types_def["celestial/meteor"] then
   newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/meteor", name = "Meteor", description = "Celestial combat magic that calls down meteors from above." }
   load("/data-classastromancer/talents/celestial/meteor.lua")
end


if not Talents.talents_types_def["celestial/paeans"] then
   newTalentType{ allow_random=true, no_silence=true, is_spell=true, generic=true, type="celestial/paeans", name = "Paeans", description = "Sing the glory of the planetary spheres." }
   load("/data-classastromancer/talents/celestial/paean.lua")
end

-- if not Talents.talents_types_def["celestial/comet"] then
--    newTalentType{ allow_random=true, no_silence=true, is_spell=true, type="celestial/comet", name = "Comet", description = "The approach of a comet to Shandral always heralds great changes." }
--    load("/data-classastromancer/talents/celestial/comet.lua")
-- end

load("/data-classastromancer/talents/chronomancy/chronomancy.lua")