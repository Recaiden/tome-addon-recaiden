newTalent{
	name = "Heavy Tread", short_name = "REK_DEML_BATTLEWAGON_HEAVY",
	type = {"steamtech/battlewagon", 1},	require = steam_req_high1,	points = 5,
	mode = "passive",
	no_unlearn_last = true,
	on_learn = function(self, t)
		local level = self:getTalentLevelRaw(t)
		if level == 1 then
			for inven_id, inven in pairs(self.inven) do
				if inven.worn then
					for item, o in ipairs(inven) do
						if o and item and o.wielder and o.wielder.max_life then
							t.callbackOnWear(self, t, o, false)
						end
					end
				end
			end
		end
		updateSteelRider(self)
	end,
	on_unlearn = function(self, t)
		local level = self:getTalentLevelRaw(t)
		if level == 0 then
			for inven_id, inven in pairs(self.inven) do
				if inven.worn then
					for item, o in ipairs(inven) do
						if o and item and o.wielder and o.wielder.max_life and o.wielder.max_hull then
							self:onTakeoff(o, inven_id, true)
							self:onWear(o, inven_id, true)
						end
					end
				end
			end
		end
		updateSteelRider(self)
	end,
	getHullBoost = function(self, t) return self:combatTalentScale(t, 50, 300) end,
	getKnockImmune = function(self, t) return math.min(1, self:combatTalentScale(t, 0.1, 0.90, 0.5)) end,
	getRamBoost = function(self, t) return self:combatTalentScale(t, 0.3, 0.90) end,
	callbackOnWear = function(self, t, o, fBypass)
		if not o then return end
		if not o.wielder then return end
		if not o.wielder.max_life then return end
		if o.wielder.max_hull then return end
		local amt = o.wielder.max_life
		--rewear it with new stats
		local _, _, inven_id = self and self:findInAllInventoriesByObject(o)
		self:onTakeoff(o, inven_id, true)
		o.wielder.max_hull = math.ceil(amt * 0.75)
		o.wielder.max_life = math.floor(amt * 0.25)
		self:onWear(o, inven_id, true)
	end,
	callbackOnTakeoff = function(self, t, o, fBypass)
		if not o then return end
		if not o.wielder then return end
		if not o.wielder.max_life then return end
		if not o.wielder.max_hull then return end
		o.wielder.max_life = o.wielder.max_life + o.wielder.max_hull
		o.wielder.max_hull = nil
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "max_hull", t.getHullBoost(self,t))
	end,
	info = function(self, t)
		return ([[Upgrade your ride into a heavy-duty armored fighting vehicle with %d additional points of hull. This also converts 75%% of bonus life on items into bonus hull.
The sheer mass of your ride gives Ramming Speed and Full Throttle %d%% more impact damage.
While riding, you have %d%% resistance to knockback and gain 1 size category. 

#{italic}#Your battlewagon is both an unstoppable force and an immovable object.#{normal}#]]):format(t.getHullBoost(self, t), t.getKnockImmune(self, t)*100, t.getRamBoost(self, t)*100)
	end,
}

newTalent{
	name = "Main Guns", short_name = "REK_DEML_BATTLEWAGON_MAIN_GUNS",
	type = {"steamtech/battlewagon", 2},
	require = steam_req_high2,
	points = 5,
	mode = "passive",
	cooldown = 5,
	getMissileRadius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 4)) end,
	getMissileDamage = function(self, t) return self:combatTalentSteamDamage(t, 20, 230) end,
	getGaussDamage = function(self, t) return self:combatTalentSteamDamage(t, 30, 380) end,
	getHarpoonDamage = function(self, t) return self:combatTalentSteamDamage(t, 60, 180) end,	
	on_learn = function(self, t)
		local lev = self:getTalentLevel(t)
		if not self:knowTalent(self:getTalentFromId(self.T_REK_DEML_MG_MISSILE)) then
			self:learnTalent(self.T_REK_DEML_MG_MISSILE, true, 1, {no_unlearn=true})
		end
		if lev >= 2 and not self:knowTalent(self:getTalentFromId(self.T_REK_DEML_MG_GAUSS)) then
			self:learnTalent(self.T_REK_DEML_MG_GAUSS, true, 1, {no_unlearn=true})
		end
		if lev >= 3 and not self:knowTalent(self:getTalentFromId(self.T_REK_DEML_MG_HARPOON)) then
			self:learnTalent(self.T_REK_DEML_MG_HARPOON, true, 1, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		local lev = self:getTalentLevel(t)
		if lev <= 0 and self:knowTalent(self:getTalentFromId(self.T_REK_DEML_MG_MISSILE)) then
			self:unlearnTalent(self.T_REK_DEML_MG_MISSILE)
		end
		if lev < 2 and self:knowTalent(self:getTalentFromId(self.T_REK_DEML_MG_GAUSS)) then
			self:unlearnTalent(self.T_REK_DEML_MG_GAUSS)
		end
		if lev < 3 and self:knowTalent(self:getTalentFromId(self.T_REK_DEML_MG_HARPOON)) then
			self:unlearnTalent(self.T_REK_DEML_MG_HARPOON)
		end
	end,
	info = function(self, t)
		return ([[Your battlewagon mounts a variety of exotic heavy weaponry.  Gain acess to the following abilities:
  Level 1: Havoc Missiles - Deal %0.2f fire damage and Daze (#SLATE#Steampower vs Physical#LAST#) in a radius %d area.
  Level 2: Gauss Cannon - Deal %0.2f unresistable lightning damage to all targets in a range 10 line.
  Level 3: Harpoon Launcher - Deal %0.2f physical bleed damage to a single target and pull (#SLATE#checks knockback immunity#LAST#) it adjacent to you.
The main guns share a %d turn cooldown.
Steampower: increasess damage]]):format(damDesc(self, DamageType.FIRE, t.getMissileDamage(self, t)), t.getMissileRadius(self, t), damDesc(self, DamageType.LIGHTNING, t.getGaussDamage(self, t)), damDesc(self, DamageType.PHYSICAL, t.getHarpoonDamage(self, t)), self:getTalentCooldown(t))
	end,
}

newTalent{
	name = "Mayhem Engine", short_name = "REK_DEML_BATTLEWAGON_MAYHEM_ENGINE",
	type = {"steamtech/battlewagon", 3},
	require = steam_req_high3,
	points = 5,
	mode= "passive",
	getCDReduce = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3)) end,
	callbackOnKill = function(self, t, src, death_note)
		if self:reactionToward(src) >= 0 then return end
		game:onTickEnd(function()
										 if self:isTalentCoolingDown(self.T_REK_DEML_ENGINE_RAMMING_SPEED) then
											 self:alterTalentCoolingdown(self.T_REK_DEML_ENGINE_RAMMING_SPEED, -1000)
										 end
										 if self:isTalentCoolingDown(self.T_REK_DEML_MG_MISSILE) then
											 self:alterTalentCoolingdown(self.T_REK_DEML_MG_MISSILE, -1000)
										 end
										 if self:isTalentCoolingDown(self.T_REK_DEML_MG_GAUSS) then
											 self:alterTalentCoolingdown(self.T_REK_DEML_MG_GAUSS, -1000)
										 end
										 if self:isTalentCoolingDown(self.T_REK_DEML_MG_HARPOON) then	 
											 self:alterTalentCoolingdown(self.T_REK_DEML_MG_HARPOON, -1000)
										 end
									 end)
	end,
	info = function(self, t)
		return ([[Push your battlewagon harder as the battle intensifies.
Whenever you kill an enemy, the cooldowns of Ramming Speed and your Main Guns are reset.
When you detonate an explosive charge or mecharachnid mine, the cooldowns are reduced by %d.]]):format(t.getCDReduce(self, t))
	end,
}

newTalent{
	name = "Choose Runeplate", short_name = "REK_DEML_CHOOSE_RUNE",
	type = {"steamtech/other", 1},
	points = 1,
	no_energy = true,
	cooldown = 0,
	no_npc_use = true,
	filterObject = function(self, t, o)
		if o.subtype == "rune" then return true end
		return false
	end,
	action = function(self, t)
		local inven = self:getInven("INVEN")
		local d = self:showInventory("Which rune do you wish to apply?", inven, function(o) return t.filterObject(self, ct, o) end, nil)
		d.action = function(o, item) self:talentDialogReturn(true, o, item) return false end
		local ret, o, item = self:talentDialog(d)
		if not ret then return nil end
		self.runeplate_inscription = o
		self.__inscription_data_fake = o.inscription_data
		local tal = self:getTalentFromId("T_"..o.inscription_talent.."_1")
		local tal_desc = tostring(self:getTalentFullDescription(tal, 1, nil, 1))
		local tal_name = tal.name
		game.logSeen(self, "#ORANGE#You apply %s to your battlewagon's runeplate!#LAST#", tal_name)
		self.__inscription_data_fake = nil
		self:removeObject(inven, item)
		self:startTalentCooldown(self:getTalentFromId(self.T_REK_DEML_BATTLEWAGON_RUNEPLATE))
		return true
	end,
	info = function(self, t)  
	return ([[Choose a rune to apply to your battlewagon, removing the object from your inventory. Once choosen, you can activate the rune while riding.	The rune will retain the power and any stat scaling it may have had, but its cooldown is based on this talent.	The chosen does not count toward your limit for the type or total maximum numbers of inscriptions. The chosen rune may be overwritten by using this talent again.]]) 
	end,
}

newTalent{
	name = "Activate Runeplate", short_name = "REK_DEML_BATTLEWAGON_RUNEPLATE",
	type = {"steamtech/battlewagon", 4},
	require = steam_req_high4,
	points = 5,
	steam = 10,
	cooldown = function(self, t) return math.max(10, math.floor(self:combatTalentScale(t, 30, 12, 0.75))) end,
	innate = true,
	on_pre_use = function(self, t) return self:hasEffect(self.EFF_REK_DEML_RIDE) end,
	on_learn = function(self, t)
		if not self:knowTalent(self:getTalentFromId(self.T_REK_DEML_CHOOSE_RUNE)) then
			self:learnTalent(self.T_REK_DEML_CHOOSE_RUNE, true, 1, {no_unlearn=true})
		end
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(self:getTalentFromId(self.T_REK_DEML_BATTLEWAGON_RUNEPLATE)) and self:knowTalent(self:getTalentFromId(self.T_REK_DEML_CHOOSE_RUNE)) then
			self:unlearnTalent(self.T_REK_DEML_CHOOSE_RUNE)
		end
	end,
	action = function(self, t)
		if not self.runeplate_inscription then return false end
		local o = self.runeplate_inscription
		self.__inscription_data_fake = o.inscription_data
		self.__runeplate_in_progress = true
		local tal = self:getTalentFromId("T_"..o.inscription_talent.."_1")
		self:callTalent(tal.id, "action")
		self.__inscription_data_fake = nil
		self.__runeplate_in_progress = nil
		self:startTalentCooldown(t)
		return true
	end,
	no_energy = function(self, t)
		if self.runeplate_inscription then 
			local o = self.runeplate_inscription
			self.__inscription_data_fake = o.inscription_data
			local tal = self:getTalentFromId("T_"..o.inscription_talent.."_1")
			local energy = util.getval(tal.no_energy, self, tal)
			self.__inscription_data_fake = nil
			return energy
		end
		return false
	end,
	info = function(self, t) 
		local cd = t.cooldown(self, t)
		if not self.runeplate_inscription then 
			return ([[The chassis of your battlewagon serves as a place to inscribe an additional inscription (though since it is not alive, it can only be a rune, not an infusion or injector).
			
			Use your 'Choose Runeplate' talent to choose a rune to apply. Once choosen, you can use the rune by activating this talent.	The inscription will inherit the power and any stat scaling the inscription may have had, but the cooldown is based solely on this talent.]]):format(cd) 
		else
			local o = self.runeplate_inscription
			self.__inscription_data_fake = o.inscription_data
			local tal = self:getTalentFromId("T_"..o.inscription_talent.."_1")
			local tal_desc = tal.info(self, tal) --tostring(self:getTalentFullDescription(tal, 1, nil, 1))
			local tal_name = tal.name
			local color = "#PURPLE#"
			self.__inscription_data_fake = nil
			return ([[Use mana-charged steam to invoke your runeplate. You may permanently replace the rune with another by using 'Choose Runeplate' again. Note that this talent will be put on cooldown.
			
			#GOLD#Runeplate Effect:#LAST#
			%s]]):format(tal_desc)
		end
	end,
}
