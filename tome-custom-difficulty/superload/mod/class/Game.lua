require "engine.class"
require "engine.GameTurnBased"
require "engine.interface.GameMusic"
require "engine.interface.GameSound"
require "engine.interface.GameTargeting"
local KeyBind = require "engine.KeyBind"
local Savefile = require "engine.Savefile"
local DamageType = require "engine.DamageType"
local Zone = require "mod.class.Zone"
local Tiles = require "engine.Tiles"
local Map = require "engine.Map"
local Level = require "engine.Level"
local Birther = require "mod.dialogs.Birther"
local Astar = require "engine.Astar"
local DirectPath = require "engine.DirectPath"
local Shader = require "engine.Shader"
local HighScores = require "engine.HighScores"
local FontPackage = require "engine.FontPackage"

local NicerTiles = require "mod.class.NicerTiles"
local GameState = require "mod.class.GameState"
local Store = require "mod.class.Store"
local Trap = require "mod.class.Trap"
local Grid = require "mod.class.Grid"
local Actor = require "mod.class.Actor"
local Party = require "mod.class.Party"
local Player = require "mod.class.Player"
local NPC = require "mod.class.NPC"

local DebugConsole = require "engine.DebugConsole"
local FlyingText = require "engine.FlyingText"
local Tooltip = require "mod.class.Tooltip"
local BigNews = require "mod.class.BigNews"

local Calendar = require "engine.Calendar"
local Gestures = require "engine.ui.Gestures"

local Dialog = require "engine.ui.Dialog"
local MapMenu = require "mod.dialogs.MapMenu"

local _M = loadPrevious(...)
local base_ng = _M.newGame

-- Measured in 100 energy ticks?
function _M:noStairsTime()
   local nb = 2
   if game.rek_dif_stairwait then nb = game.rek_dif_stairwait
   elseif game.difficulty == game.DIFFICULTY_EASY then nb = 0
   elseif game.difficulty == game.DIFFICULTY_NIGHTMARE then nb = 3
   elseif game.difficulty == game.DIFFICULTY_INSANE then nb = 5
   elseif game.difficulty == game.DIFFICULTY_MADNESS then nb = 9
   end
   return nb * 10
end

-- Need to get at player object right after Birther is returned, so replace the whole function.
function _M:newGame()
   self.party = Party.new{}
   local player = Player.new{name=self.player_name, game_ender=true}
   self.party:addMember(player, {
			   control="full",
			   type="player",
			   title="Main character",
			   main=true,
			   orders = {target=true, anchor=true, behavior=true, leash=true, talents=true},
   })
   self.party:setPlayer(player)
   
   -- Create the entity to store various game state things
   self.state = GameState.new{}
   local birth_done = function()
      if self.state.birth.__allow_rod_recall then self.state:allowRodRecall(true) self.state.birth.__allow_rod_recall = nil end
      if self.state.birth.__allow_transmo_chest and profile.mod.allow_build.birth_transmo_chest then
	 self.state.birth.__allow_transmo_chest = nil
	 local chest = self.zone:makeEntityByName(self.level, "object", "TRANSMO_CHEST")
	 if chest then
	    self.zone:addEntity(self.level, chest, "object")
	    self.player:addObject(self.player:getInven("INVEN"), chest)
	 end
      end
      
      for i = 1, 50 do
	 local o = self.state:generateRandart{add_pool=true}
	 self.zone.object_list[#self.zone.object_list+1] = o
      end
      
      if config.settings.cheat then self.player.__cheated = true end

      if game.__mod_info then
         local beta = engine.version_hasbeta()
         self.player.__created_in_version = game.__mod_info.version_name..(beta and "-"..beta or "")
      end
      
      if self.player.max_life_bonus then
         self.player.max_life = self.player.max_life + self.player.max_life_bonus
         self.player.life = self.player.life + self.player.max_life_bonus
         self.player.max_life_bonus = nil
      end
      
      self.player:recomputeGlobalSpeed()
      self:rebuildCalendar()
      
      -- Force the hotkeys to be sorted.
      self.player:sortHotkeys()
      
      -- Register the character online if possible
      self.player:getUUID()
      self:updateCurrentChar()
   end
   
   if not config.settings.tome.tactical_mode_set then
      self.always_target = true
   else
      self.always_target = config.settings.tome.tactical_mode
   end
   local nb_unlocks, max_unlocks, categories = self:countBirthUnlocks()
   local unlocks_order = { class=1, race=2, cometic=3, other=4 }
   local unlocks = {}
   for cat, d in pairs(categories) do unlocks[#unlocks+1] = {desc=d.nb.."/"..d.max.." "..cat, order=unlocks_order[cat] or 99} end
   table.sort(unlocks, "order")
   self.creating_player = true
   self.extra_birth_option_defs = {}
   self:triggerHook{"ToME:extraBirthOptions", options = self.extra_birth_option_defs}
   local birth; birth = Birther.new("Character Creation ("..table.concat(table.extract_field(unlocks, "desc", ipairs), ", ").." unlocked options)", self.player, {"base", "world", "difficulty", "permadeath", "race", "subrace", "sex", "class", "subclass" },
				    function(loaded)
				       if not loaded then
					  self.calendar = Calendar.new("/data/calendar_"..(self.player.calendar or "allied")..".lua", "Today is the %s %s of the %s year of the Age of Ascendancy of Maj'Eyal.\nThe time is %02d:%02d.", 122, 167, 11)
					  self.player:check("make_tile")
					  self.player.make_tile = nil
					  self.player:check("before_starting_zone")
					  self.player:check("class_start_check")
					  
					  -- Save current state of extra birth options.
					  self.player.extra_birth_options = {}
					  for _, option in ipairs(self.extra_birth_option_defs) do
					     if option.id then
						self.player.extra_birth_options[option.id] = config.settings.tome[option.id]
					     end
					  end
					  
					  -- Configure & create the worldmap
					  self.player.last_wilderness = self.player.default_wilderness[3] or "wilderness"
					  game:onLevelLoad(self.player.last_wilderness.."-1", function(zone, level)
							      game.player.wild_x, game.player.wild_y = game.player.default_wilderness[1], game.player.default_wilderness[2]
							      if type(game.player.wild_x) == "string" and type(game.player.wild_y) == "string" then
								 local spot = level:pickSpot{type=game.player.wild_x, subtype=game.player.wild_y} or {x=1,y=1}
								 game.player.wild_x, game.player.wild_y = spot.x, spot.y
							      end
					  end)
					  
					  -- Generate
					  if self.player.__game_difficulty then self:setupDifficulty(self.player.__game_difficulty) end

					  -- Custom difficulty copying
					  if self.player.rek_dif_stairwait then
					     self.rek_dif_stairwait = self.player.rek_dif_stairwait
					  end
					  if self.player.rek_dif_ezstatus then
					     self.rek_dif_ezstatus = self.player.rek_dif_ezstatus
					  end
					  
					  self:setupPermadeath(self.player)
					  --self:changeLevel(1, "test")
					  self:changeLevel(self.player.starting_level or 1, self.player.starting_zone, {force_down=self.player.starting_level_force_down, direct_switch=true})
					  
					  print("[PLAYER BIRTH] resolve...")
					  self.player:resolve()
					  self.player:resolve(nil, true)
					  self.player.energy.value = self.energy_to_act
					  Map:setViewerFaction(self.player.faction)
					  self.player:updateModdableTile()
					  
					  self.paused = true
					  print("[PLAYER BIRTH] resolved!")
					  local birthend = function()
					     local d = require("engine.dialogs.ShowText").new("Welcome to #LIGHT_BLUE#Tales of Maj'Eyal", "intro-"..self.player.starting_intro, {name=self.player.name}, nil, nil, function()
												 self.player:resetToFull()
												 self.player:registerCharacterPlayed()
												 self.player:onBirth(birth)
												 -- For quickbirth
												 savefile_pipe:push(self.player.name, "entity", self.party, "engine.CharacterVaultSave")
												 
												 self.player:grantQuest(self.player.starting_quest)
												 self.creating_player = false
												 
												 birth_done()
												 self.player:check("on_birth_done")
												 self:setTacticalMode(self.always_target)
												 self:triggerHook{"ToME:birthDone"}
												 
												 if __module_extra_info.birth_done_script then loadstring(__module_extra_info.birth_done_script)() end
																										   end, true)
					     self:registerDialog(d)
					     if __module_extra_info.no_birth_popup then d.key:triggerVirtual("EXIT") end
					  end
					  
					  if self.player.no_birth_levelup or __module_extra_info.no_birth_popup then birthend()
					  else self.player:playerLevelup(birthend, true) end
					  -- Player was loaded from a premade
				       else
					  self.calendar = Calendar.new("/data/calendar_"..(self.player.calendar or "allied")..".lua", "Today is the %s %s of the %s year of the Age of Ascendancy of Maj'Eyal.\nThe time is %02d:%02d.", 122, 167, 11)
					  Map:setViewerFaction(self.player.faction)
					  if self.player.__game_difficulty then self:setupDifficulty(self.player.__game_difficulty) end
					  self:setupPermadeath(self.player)
					  
					  -- Configure & create the worldmap
					  self.player.last_wilderness = self.player.default_wilderness[3] or "wilderness"
					  game:onLevelLoad(self.player.last_wilderness.."-1", function(zone, level)
							      game.player.wild_x, game.player.wild_y = game.player.default_wilderness[1], game.player.default_wilderness[2]
							      if type(game.player.wild_x) == "string" and type(game.player.wild_y) == "string" then
								 local spot = level:pickSpot{type=game.player.wild_x, subtype=game.player.wild_y} or {x=1,y=1}
								 game.player.wild_x, game.player.wild_y = spot.x, spot.y
							      end
					  end)
					  
					  -- Tell the level gen code to add all the party
					  self.to_re_add_actors = {}
					  for act, _ in pairs(self.party.members) do if self.player ~= act then self.to_re_add_actors[act] = true end end
					     
					     self:changeLevel(self.player.starting_level or 1, self.player.starting_zone, {force_down=self.player.starting_level_force_down, direct_switch=true})
					     self.player:grantQuest(self.player.starting_quest)
					     self.creating_player = false
					     
					     -- Add all items so they regen correctly
					     self.player:inventoryApplyAll(function(inven, item, o) game:addEntity(o) end)
					     
					     birth_done()
					     self.player:check("on_birth_done")
					     self:setTacticalMode(self.always_target)
					     self:triggerHook{"ToME:birthDone"}
				       end
																																end, quickbirth, 800, 600)
   self:registerDialog(birth)
end


function _M:save()
	self.total_playtime = (self.total_playtime or 0) + (os.time() - (self.last_update or self.real_starttime))
	self.last_update = os.time()
	return class.save(self,
			  self:defaultSavedFields{difficulty=true, permadeath=true, to_re_add_actors=true, party=true, _chronoworlds=true, total_playtime=true, on_level_load_fcts=true, visited_zones=true, bump_attack_disabled=true, show_npc_list=true, always_target=true,
						  rek_dif_stairwait=true,
						  rek_dif_ezstatus=true,
			  }, true)
end

return _M
