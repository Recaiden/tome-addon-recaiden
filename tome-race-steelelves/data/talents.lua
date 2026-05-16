newTalentType{ type="race/macilore", name = "Macilore", generic = true, description = "The various racial bonuses a steel elf character can have."}

local Stats = require "engine.interface.ActorStats"
local Map = require "engine.Map"

racial_req1 = {
	level = function(level) return 0 + (level-1)  end,
}
racial_req2 = {
	level = function(level) return 8 + (level-1)  end,
}
racial_req3 = {
	level = function(level) return 16 + (level-1)  end,
}
racial_req4 = {
	level = function(level) return 24 + (level-1)  end,
}

-- activate to refresh a CLOSEIN talent, passively pull enemies when combat begins
-- Endurance of Steel - block based on weapon damage

newTalent{
	short_name="REK_STEEL_WIELDING",
	name = "Wielding of Steel",
	type = {"race/macilore", 1},
	require = racial_req1,
	points = 5,
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 45, 25)) end,
	-- called by _M:getOffHandMult superload function in mod\class\interface\Combat.lua
	getoffmult = function(self,t) return 0.1 end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "allow_any_dual_weapons", 1)
	end,
	getSpeed = function(self, t) return 20 end,
	getDuration = function(self, t) return 5 end,
	tactical = { BUFF = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_REK_STEEL_WIELDING, t.getDuration(self, t), {src=self, speed=t.getSpeed(self, t)})
		return true
	end,
	info = function(self, t)
		return ([[You have developed incredible coordination through intensive training and a bond with your weapons, and can wield a one-handed weapon in each hand and do +%d%% damage with your off-hand weapon.
Activate this talent to increase your weapon speed by %d%% for %d turns.]]):format(t.getoffmult(self, t)*100, t.getSpeed(self, t), t.getDuration(self, t))
	end,
}

newTalent{
	short_name = "REK_STEEL_RUSH",
	name = "Allure of Steel",
	type = {"race/macilore", 2},
	require = racial_req2,
	points = 5,
	callbackOnCombat = function(self, t, state)
		if state == true then
			local tgts = {}
			tg = {type="ball", range=0, friendlyfire=false, radius=10, talent=t}
			self:project(
				tg, self.x, self.y,
				function(px, py)
					local target = game.level.map(px, py, Map.ACTOR)
					if not target then return end
					if self:reactionToward(target) < 0 and not tgts[target] then
						tgts[target] = true
						local ox, oy = target.x, target.y
						if target:canBe("knockback") then
							target:pull(self.x, self.y, 3)
							if target.x ~= ox or target.y ~= oy then game.logSeen(target, "%s is pulled in by the Allure of Steel!", target.name:capitalize()) end
						end
					end
			end)
		end
	end,	
	no_energy = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 45, 25)) end,
	on_pre_use = function(self, t, silent)
		local options = t.getOptions(self, t)
		if #options == 0 then return false end
		return true
	end,
	getOptions = function(self, t)
		local o = {}
		for id, lvl in pairs(self.talents) do
			local t = self.talents_def[id]
			if t.tactical then
				local tac_resolved = t.tactical
				if type(tac_resolved) == "function" then
					tac_resolved = util.getval(t.tactical, self, t) or {}
				end
				if tac_resolved["closein"] then
					o[#o+1] = t.name
				end
			end
		end
		return o
	end,
	action = function(self, t)
		local o = {}
		for id, lvl in pairs(self.talents) do
			local t = self.talents_def[id]
			if t.tactical then
				local tac_resolved = t.tactical
				if type(tac_resolved) == "function" then
					tac_resolved = util.getval(t.tactical, self, t) or {}
				end
				if tac_resolved["closein"] then
					o[#o+1] = id
				end
			end
		end
		if #o > 0 then
			local selected = rng.table(o)
			self.talents_cd[selected] = nil
			self.changed = true
			game:playSoundNear(self, "talents/spell_generic2")
			return true	
		end
		return false
	end,
	info = function(self, t)
		local possibles = t.getOptions(self, t)
		local str = ([[Whenever combat begins, enemies are drawn 3 spaces closer to you by a strange magnetism.

Use this talent to instantly refresh the cooldown of a random talent that can be used to close the distance to an enemy:]]):tformat()
		if #possibles == 0 then
			str = str..([[

* None known]])
		end
		for _, talentname in pairs(possibles) do
			str = str..([[

* %s]]):tformat(talentname)
		end
		return str
	end,
}

newTalent{
	short_name = "REK_STEEL_POWER",
	name = "Power of Steel",
	type = {"race/macilore", 3},
	require = racial_req3,
	points = 5,
	mode = "passive",
	critChance = function(self, t) return self:combatTalentScale(t, 3, 10, 0.75) end,
	critPower = function(self, t) return self:combatTalentScale(t, 5, 20, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_generic_crit", t.critChance(self, t))
		self:talentTemporaryValue(p, "combat_critical_power", t.critPower(self, t))
	end,
	info = function(self, t)
		return ([[A Steel Elf knows the perfect place to strike for devastating effect.
		Increases critical chance by %d%% and critical strike power by %d%%.]]):tformat(t.critChance(self, t), t.critPower(self, t))
	end,
}

newTalent{
	short_name = "REK_STEEL_ENDURANCE",
	name = "Endurance of Steel",
	type = {"race/macilore", 4},
	require = racial_req4,
	points = 5,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 5, 20, 6)) end,
	tactical = { DEFEND = 2 },
	getProperties = function(self, t)
		local shield1, combat1, shield2, combat2 = self:hasShield()
		local p = {
			sp = (combat1 and combat1.spellplated or false) or (combat2 and combat2.spellplated or false),
			ref = (combat1 and combat1.reflective or false) or (combat2 and combat2.reflective or false),
			br = (combat1 and combat1.bloodruned or false) or (combat2 and combat2.bloodruned or false),
		}
		return p
	end,
	getBlockValue = function(self, t)
		local block = self:combatShieldBlock() or 0
		if self:getInven("MAINHAND") then
			local weapon = self:getInven("MAINHAND")[1]
			if weapon then block = block + (weapon.combat.dam or 1) * 2 end
		end
		if self:getInven("OFFHAND") then
			local weapon = self:getInven("OFFHAND")[1]
			if weapon then block = block + (weapon.combat.dam or 1) * 2 end
		end
		return block
	end,
	getBonusDamage = function(self, t)
		local bonus = 0

		return bonus
	end,
	getBlockedTypes = function(self, t)
		local shield1, combat1, shield2, combat2 = self:hasShield()
		local bt = {
			[DamageType.PHYSICAL]= true,
			[DamageType.FIRE] = true,
			[DamageType.LIGHTNING] = true,
			[DamageType.COLD] = true,
			[DamageType.ACID] = true,
			[DamageType.NATURE] = true,
			[DamageType.BLIGHT] = true,
			[DamageType.LIGHT] = true,
			[DamageType.DARKNESS] = true,
			[DamageType.ARCANE] = true,
			[DamageType.TEMPORAL] = true,
		}
		return bt, "None"
	end,
	action = function(self, t)
		local properties = t.getProperties(self, t)
		local bt, bt_string = t.getBlockedTypes(self, t)
		self:setEffect(self.EFF_BLOCKING, 2, {power = t.getBlockValue(self, t), d_types=bt, bonus_block_pct = bonuses, properties=properties, from_block=true})
		return true
	end,
	info = function(self, t)
		return ([[Whirl your weapons about to block threats with a wall of steel, reducing all non-Mind damage by %d (based on the damage of your weapons and the strength of your shields). 

If you block all of an attack's damage, the attacker will be vulnerable to a deadly counterstrike (the next weapon attack will instead deal 200%% damage) for one turn.  Counterstrike can normally only effect one enemy per block.  
If any damage was successfully blocked this effect will be removed at the start of your turn.]]):format(t.getBlockValue(self, t))
	end,
}
