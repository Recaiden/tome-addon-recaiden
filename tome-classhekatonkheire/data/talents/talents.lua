local Talents = require "engine.interface.ActorTalents"
local Tiles = require "engine.Tiles"
local Entity = require "engine.Entity"

damDesc = Talents.main_env.damDesc

mag_req_slow = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)*4  end,
}
mag_req1 = {
	stat = { mag=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
mag_req2 = {
	stat = { mag=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
mag_req3 = {
	stat = { mag=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
mag_req4 = {
	stat = { mag=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
mag_req5 = {
	stat = { mag=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
mag_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
mag_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
mag_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
mag_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
mag_req_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

eye_req_high1 = {
	stat = { mag=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1) end,
	special={desc=_t"Know Wandering Eyes", fct=function(self)
						 return self:getTalentLevelRaw(self.T_REK_HEKA_HEADLESS_EYES) >= 1
	end},
}
eye_req_high2 = {
	stat = { mag=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
eye_req_high3 = {
	stat = { mag=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
eye_req_high4 = {
	stat = { mag=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
eye_req_high5 = {
	stat = { mag=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}


str_req_slow = {
	stat = { str=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)*4  end,
}
str_req1 = {
	stat = { str=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
str_req2 = {
	stat = { str=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
str_req3 = {
	stat = { str=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
str_req4 = {
	stat = { str=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
str_req5 = {
	stat = { str=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
str_req_high1 = {
	stat = { str=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
str_req_high2 = {
	stat = { str=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
str_req_high3 = {
	stat = { str=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
str_req_high4 = {
	stat = { str=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
str_req_high5 = {
	stat = { str=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

newTalent{
	name = "Hands Pool",
	type = {"base/class", 1},
	info = "Allows you to have a pool of 100 hands, used for hekatonkheire abilities.",
	mode = "passive",
	hide = "always",
	no_unlearn_last = true,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "hands_regen", 10)
	end,
}

-- shared
if not Talents.talents_types_def["technique/helping-hands"] then
   newTalentType{ allow_random=true, type="technique/helping-hands", name = "Helping Hands", description = "Many hands make light work." }
   load("/data-classhekatonkheire/talents/helping-hands.lua")
end

if not Talents.talents_types_def["spell/headless-horror"] then
   newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="spell/headless-horror", name = "Headless Horror", description = "More eyes, bigger eyes, better eyes." }
   load("/data-classhekatonkheire/talents/headless-horror.lua")
end

if not Talents.talents_types_def["spell/otherness"] then
   newTalentType{ allow_random=true, is_spell=true, no_silence=true, generic=true, type="spell/otherness", name = "Otherside", description = "Look over and see through." }
   load("/data-classhekatonkheire/talents/otherness.lua")
end

if not Talents.talents_types_def["spell/eyesight"] then
   newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="spell/eyesight", name = "Eyesight", min_lev = 10, description = "If you look hard enough, that alone is enough to kill." }
   load("/data-classhekatonkheire/talents/eyesight.lua")
end

-- hekatonkhiere
if not Talents.talents_types_def["spell/shambler"] then
   newTalentType{ allow_random=true, is_spell=true, type="spell/shambler", name = "Shambler", description = "Walk steadily forward.  Don't worry; they will come to you.  These are spells, but can be used while silenced." }
   load("/data-classhekatonkheire/talents/shambler.lua")
end

if not Talents.talents_types_def["technique/titanic-blows"] then
   newTalentType{ allow_random=true, type="technique/titanic-blows", name = "Titanic Blows", description = "Crush your enemies with slow heavy hits." }
   load("/data-classhekatonkheire/talents/titanic.lua")
end

if not Talents.talents_types_def["technique/harming-hands"] then
   newTalentType{ allow_random=true, type="technique/harming-hands", name = "Harming Hands", description = "Grab, choke, and smash." }
   load("/data-classhekatonkheire/talents/harming-hands.lua")
end

if not Talents.talents_types_def["technique/splintered-lord"] then
   newTalentType{ allow_random=true, is_spell=true, type="technique/splintered-lord", name = "Splintered Lord", min_lev = 10, description = "Separate yourself into ever more pieces and fully attend to the battle." }
   load("/data-classhekatonkheire/talents/splintered-lord.lua")
end

if not Talents.talents_types_def["spell/mountainshaper"] then
   newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="spell/mountainshaper", name = "Mountainshaper", description = "With his every step, the earth trembles.  With his every word, the land awakes." }
   load("/data-classhekatonkheire/talents/mountainshaper.lua")
end

--argosine
if not Talents.talents_types_def["spell/sybarite"] then
   newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="spell/sybarite", name = "Sybarite", description = "At her passage, the people kneel, and with her word, they rise to dance." }
   load("/data-classhekatonkheire/talents/argosine-sybarite.lua")
end

-- if not Talents.talents_types_def["spell/watcher"] then
--    newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="spell/watcher", name = "Watcher", description = "You've got to keep an eye on your eyes if you want them to succeed." }
--    load("/data-classhekatonkheire/talents/argosine-watcher.lua")
-- end

if not Talents.talents_types_def["spell/veiled-shepherd"] then
   newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="spell/veiled-shepherd", name = "Veiled Shepherd", description = "You stand between this place and the other place, controlling the flow of eyes." }
   load("/data-classhekatonkheire/talents/argosine-veiled.lua")
end

-- if not Talents.talents_types_def["spell/oubliette"] then
--    newTalentType{ allow_random=true, is_spell=true, no_silence=true, type="spell/oubliette", name = "Oubliette", description = "Is it not a terrible thing, to die alone and forgotten?" }
--    load("/data-classhekatonkheire/talents/argosine-oubliette.lua")
-- end

-- if not Talents.talents_types_def["spell/eyebite"] then
--    newTalentType{ allow_random=true, is_spell=true, type="spell/eyebite", name = "Eyebite", min_lev = 10, description = "Your stare alone can reduce foes to dust." }
--    load("/data-classhekatonkheire/talents/argosine-eyebite.lua")
-- end
