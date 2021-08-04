local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"
newEffect{
   name = "REK_LIGHTNING_SPEED", image = "talents/lightning_speed.png",
   desc = "Racing Wings",
   long_desc = function(self, eff) return ("Soar through the air, moving %d%% faster. It also increases your resistance to damage by 30%%."):format(eff.power) end,
   type = "physical",
   subtype = { speed=true },
   status = "beneficial",
   parameters = {},
   on_gain = function(self, err) return "#Target# takes wing!.", "+Racing Speed" end,
   on_lose = function(self, err) return "#Target# lands.", "-Racing Speed" end,
   get_fractional_percent = function(self, eff)
      local d = game.turn - eff.start_turn
      return util.bound(360 - d / eff.possible_end_turns * 360, 0, 360)
   end,
   activate = function(self, eff)
      eff.start_turn = game.turn
      eff.possible_end_turns = 10 * (eff.dur+1)
      eff.moveid = self:addTemporaryValue("movement_speed", eff.power/100)
      eff.resistsid = self:addTemporaryValue("resists", { all=30 })
      if self.ai_state then eff.aiid = self:addTemporaryValue("ai_state", {no_talents=1}) end -- Make AI not use talents while using it
      if core.shader.active(4) then
	 -- exceptions till I can properly add it to the particle generator
	 local vistype = DamageType.PHYSICAL
	 local source = self.rek_wyrmic_dragon_damage
	 if source then
	    vistype = source.damtype
	 end
	 local part_wings = "sandwings"
	 if vistype == DamageType.PHYSICAL then
	    part_wings = "sandwings"
	 elseif vistype == DamageType.NATURE then
	    part_wings = "poisonwings"
	 elseif vistype == DamageType.DARKNESS then
	    part_wings = "darkwings"
	 elseif vistype == DamageType.BLIGHT then
	    part_wings = "sickwings"
	 elseif vistype == DamageType.COLD then
	    part_wings = "icewings"
	 elseif vistype == DamageType.LIGHTNING then
	    part_wings = "lightningwings"
	 elseif vistype == DamageType.ACID then
	    part_wings = "acidwings"
	 end
	 
	 local bx, by = self:attachementSpot("back", true)
	 eff.particle = self:addParticles(Particles.new("shader_wings", 1, {img=part_wings, infinite=1, x=bx, y=by}))
      end
   end,
   deactivate = function(self, eff)
      if eff.particle then
	 self:removeParticles(eff.particle)
      end
      --self:removeTemporaryValue("lightning_speed", eff.tmpid)
      self:removeTemporaryValue("resists", eff.resistsid)
      self:removeTemporaryValue("resists_cap", eff.capresistsid)
      if eff.aiid then self:removeTemporaryValue("ai_state", eff.aiid) end
      self:removeTemporaryValue("movement_speed", eff.moveid)
   end,
}

newEffect{
	name = "REK_WYRMIC_BREATH_RECOVERY", image = "talents/wyrmic_guile.png",
	desc = "Deep Breath",
	long_desc = function(self, eff) return ("You are quickly recovering your breath"):format(eff.power) end,
	type = "other",
	subtype = { miscellaneous=true },
	status = "beneficial",
	parameters = {},
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		if not self:attr("no_talents_cooldown") then
			for tid, _ in pairs(self.talents_cd) do
				if tid == self.T_REK_WYRMIC_ELEMENT_BREATH then
					local t = self:getTalentFromId(tid)
					if t and not t.fixed_cooldown then
						self.talents_cd[tid] = self.talents_cd[tid] - 1
					end
				end
			end
		end
	end,
}

newEffect{
   name = "REK_WYRMIC_EMBERS", image = "talents/fiery_hands.png",
   desc = "Draconic Strikes",
   long_desc = function(self, eff) return ("Your weapons are enveloped in natural elemental energy, adding %d damage to your attacks."):format(eff.power) end,
   type = "physical",
   subtype = { fire=true },
   status = "beneficial",
   parameters = {power=10},
   activate = function(self, eff)
      local damtype = DamageType.REK_WYRMIC_NULL
      local source = self.rek_wyrmic_dragon_damage
      if source then
	 damtype = source.damtype
      end
      eff.onhit = self:addTemporaryValue("melee_project", {[damtype] = eff.power})
   end,
   deactivate = function(self, eff)
      	self:removeTemporaryValue("melee_project", eff.onhit)
   end,
}

newEffect{
   name = "REK_WYRMIC_NO_STATIC", image = "talents/static_field.png",
   desc = "Grounded",
   long_desc = function(self, eff) return ("You are electrically balanced and cannot take Static damage."):format(eff.power) end,
   type = "other",
   subtype = { lightning=true },
   status = "beneficial",
   parameters = {power=1},
   activate = function(self, eff)
   end,
   deactivate = function(self, eff)
   end,
}

newEffect{
   name = "REK_WYRMIC_SLOW_MOVE",
   desc = "Dissolution", image = "talents/slow.png",
   long_desc = function(self, eff) return ("Movement speed is reduced by %d%%."):format(eff.power*100) end,
   type = "physical",
   subtype = { nature=true },
   status = "detrimental",
   parameters = {power = 1},
   on_gain = function(self, err) return nil, "+Slow movement" end,
   on_lose = function(self, err) return nil, "-Slow movement" end,
   activate = function(self, eff)
      eff.speedid = self:addTemporaryValue("movement_speed", -eff.power)
   end,
   deactivate = function(self, eff)
		self:removeTemporaryValue("movement_speed", eff.speedid)
   end,
}

newEffect{
   name = "REK_WYRMIC_CORRODE", image = "talents/blightzone.png",
   desc = "Corrosion",
   long_desc = function(self, eff) return ("The target is corroded, reducing their accuracy and physical/spell/mind powers by %d"):format(eff.atk) end,
   type = "physical",
   subtype = { acid=true },
   status = "detrimental",
   parameters = { atk=5 }, no_ct_effect = true,
   on_gain = function(self, err) return "#Target# is corroded." end,
   on_lose = function(self, err) return "#Target# has shook off the effects of their corrosion." end,
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "combat_atk", -eff.atk)
      self:effectTemporaryValue(eff, "combat_spellpower", -eff.atk)
      self:effectTemporaryValue(eff, "combat_dam", -eff.atk)
      self:effectTemporaryValue(eff, "combat_mindpower", -eff.atk)
      
   end,
}

newEffect{
   name = "REK_WYRMIC_SHATTERED_ICE", image = "talents/rek_wyrmic_cold_shield.png",
   desc = "Shattered Ice",
   long_desc = function(self, eff) return ("The target's ice armor is shattered, reducing their damage reduction by %d."):format(eff.power) end,
   type = "other",
   subtype = { cold=true },
   status = "detrimental",
   parameters = { power=0 }, no_ct_effect = true,
   on_gain = function(self, err) return "#Target#'s ice armor cracks." end,
   on_lose = function(self, err) return "#Target#'s ice armor reforms." end,
   updateEffect = function(self, old_eff, new_eff, e)
      -- Put this in __tmpvals so stuff like copyEffect doesn't break
      old_eff.__tmpvals = old_eff.__tmpvals or {}
      new_eff.__tmpvals = new_eff.__tmpvals or {}
      if old_eff.__tmpvals.power then
	 self:removeTemporaryValue("flat_damage_armor", old_eff.__tmpvals.power)
      end
      new_eff.__tmpvals.power = self:addTemporaryValue("flat_damage_armor", {all=old_eff.power * -1})
   end,
   on_merge = function(self, old_eff, new_eff, e)
      new_eff.power = math.min(
	 old_eff.power+5,
	 self:callTalent(self.T_REK_WYRMIC_COLD_SHIELD, "getArmor") or 0
      )
      e.updateEffect(self, old_eff, new_eff, e)
      return new_eff
   end,
   activate = function(self, eff, e)
      e.updateEffect(self, eff, eff, e)
   end,
   deactivate = function(self, eff, e)
      self:removeTemporaryValue("flat_damage_armor", eff.__tmpvals.power)
   end,
}

newEffect{
   name = "REK_WYRMIC_AVALANCHE", image = "talents/rek_wyrmic_cold_counter.png",
   desc = "Gathering Avalanche",
   long_desc = function(self, eff) return ("The target is absorbing attacks to create a mighty avalanche."):format() end,
   type = "mental",
   subtype = { cold=true, shield=true },
   status = "beneficial",
   parameters = { defend=0.25, absorb=0.50, stored=0 }, no_ct_effect = true,
   charges = function(self, eff) return math.floor(eff.stored) end,
   on_gain = function(self, err) return "#Target# gathers ice and snow." end,
   on_lose = function(self, err) return "#Target#'s unleashes an avalanche." end,

   callbackOnTakeDamage = function(self, eff, src, x, y, type, dam, tmp)
      local dam_absorb = dam * eff.defend
      eff.stored = eff.stored + dam_absorb * eff.absorb
      game:delayedLogDamage(src or self, self, 0, ("%s(%d absorbed)#LAST#"):format(DamageType:get(type).text_color or "#aaaaaa#", dam_absorb), false)
      return {dam=dam-dam_absorb}
   end,

   callbackOnMeleeHit = function(self, eff, target, dam) 
      if self:checkHit(self:combatMindpower(), target:combatPhysicalResist(), 0, 95, 5) then
	 target:setEffect(self.EFF_DISARMED, 3, {})
      end
   end,

   activate = function(self, eff, e)
   end,
   deactivate = function(self, eff, e)
      self:project({type="ball", radius=6, friendlyfire=false}, self.x, self.y, DamageType.REK_WYRMIC_COLD, eff.stored)
      game.level.map:particleEmitter(self.x, self.y, 6, "rek_wyrmic_cold_ball", {tx=self.x, ty=self.y, radius=6})
      game:playSoundNear(self, "talents/tidalwave")
   end,
}

newEffect{
	name = "REK_WYRMIC_DISSOLVE", image = "talents/rek_wyrmic_acid_dissolve.png",
	desc = "Dissolving",
	long_desc = function(self, eff) return "The target is taking acid damage and losing one sustain per turn." end,
	on_gain = function(self, err) return "#Target# is coated in disrupting acid!", "+Dissolve" end,
	on_lose = function(self, err) return "#Target# has neutralized the acid.", "-Dissolve" end,
	type = "Physical",
	subtype = { acid=true },
	status = "detrimental",
	parameters = {power=1, apply_power=10},
	on_timeout = function(self, eff)
		if self:checkHit(eff.apply_power, self:combatMentalResist(), 0, 95, 5) then
			self:removeSustainsFilter(eff.src or self, nil, 1)
		end  
		DamageType:get(DamageType.ACID).projector(eff.src, self.x, self.y, DamageType.ACID, eff.power)
	end,
	activate = function(self, eff)
		if core.shader.allow("adv") then
			eff.particle1, eff.particle2 = self:addParticles3D("volumetric", {kind="fast_sphere", twist=2, base_rotation=90, radius=1.4, density=40,  scrollingSpeed=-0.0002, growSpeed=0.004, img="miasma_01_01"})
		end
   end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)
	end,
}

newEffect{
	name = "REK_WYRMIC_TREMORSENSE", image = "talents/track.png",
	desc = "Sensing",
	long_desc = function(self, eff) return "Improves senses, allowing the detection of unseen things." end,
	type = "physical",
	subtype = { sense=true },
	status = "beneficial",
	parameters = { range=10, actor=1, object=0, trap=0 },
	activate = function(self, eff)
		eff.rid = self:addTemporaryValue("detect_range", eff.range)
		eff.aid = self:addTemporaryValue("detect_actor", eff.actor)
		self.detect_function = eff.on_detect
		game.level.map.changed = true
		
		if self.hotkey and self.isHotkeyBound then
			local pos = self:isHotkeyBound("talent", self.T_REK_WYRMIC_SAND_TREMOR)
			if pos then
				self.hotkey[pos] = {"talent", self.T_REK_WYRMIC_SAND_TREMOR_CHARGE}
			end
		end
		
		local ohk = self.hotkey
		self.hotkey = nil -- Prevent assigning hotkey, we just did
		self:learnTalent(self.T_REK_WYRMIC_SAND_TREMOR_CHARGE, true, eff.level, {no_unlearn=true})
		self.hotkey = ohk
		
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("detect_range", eff.rid)
		self:removeTemporaryValue("detect_actor", eff.aid)
		self.detect_function = nil
		
		if self.hotkey and self.isHotkeyBound then
			local pos = self:isHotkeyBound("talent", self.T_REK_WYRMIC_SAND_TREMOR_CHARGE)
			if pos then
				self.hotkey[pos] = {"talent", self.T_REK_WYRMIC_SAND_TREMOR}
			end
		end
		
		self:unlearnTalent(self.T_REK_WYRMIC_SAND_TREMOR_CHARGE, eff.level, nil, {no_unlearn=true})      
   end,
}

newEffect{
	name = "REK_WYRMIC_VULNERABILITY_POISON", image = "talents/vulnerability_poison.png",
	desc = "Poison Vulnerability",
	long_desc = function(self, eff)
		return ("The target is afflicted with a destabilizing poison. Nature resistance is reduced by 10%% and poison resistance is reduced by %d%%."):format(eff.power)
	end,
	type = "other",
	subtype = { poison=true },
	status = "detrimental",
	parameters = {power=10, unresistable=true},
	on_gain = function(self, err) return "#Target# is vulnerable to poison!", "+Poison Vulnerability" end,
	on_lose = function(self, err) return "#Target# is no longer vulnerable to poison.", "-Poison Vulnerability" end,
	on_timeout = function(self, eff)
	end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists", {[DamageType.NATURE]=-10})
		if self:attr("poison_immune") then
			self:effectTemporaryValue(eff, "poison_immune", -eff.power / 100)
		end
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
   name = "REK_WYRMIC_TOXIC_SHOCK", image = "talents/rek_wyrmic_venom_shock.png",
   desc = "Toxic Shock",
   long_desc = function(self, eff)
      return ("The target is overwhelmed by poison and highly vulnerable. Damage resistances are reduced by 20%%."):format()
   end,
   type = "physical",
   subtype = { nature=true, stun=true },
   status = "detrimental",
   parameters = {unresistable=true},
   on_gain = function(self, err) return "#Target# is suffering from toxic shock!", "+Vulnerability" end,
   on_lose = function(self, err) return "#Target# has recovered from the toxin.", "-Vulnerability" end,
   on_timeout = function(self, eff)
   end,
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "resists", {all=-20})
      if self.rank < 4 then
	 eff.tmpid = self:addTemporaryValue("stunned", 1)
	 eff.tcdid = self:addTemporaryValue("no_talents_cooldown", 1)
	 eff.speedid = self:addTemporaryValue("movement_speed", -0.5)
      end
   end,
   deactivate = function(self, eff)
      if eff.tmpid then
	 self:removeTemporaryValue("stunned", eff.tmpid)
	 self:removeTemporaryValue("no_talents_cooldown", eff.tcdid)
	 self:removeTemporaryValue("movement_speed", eff.speedid)
      end
   end,
}

newEffect{
   name = "REK_WYRMIC_TOXIC_WATCH", image = "talents/rek_wyrmic_venom_shock.png",
   desc = "Toxin Accumulation",
   long_desc = function(self, eff)
      if self:attr("instakill_immune") then
	 return ("The target is afflicted with a lethal poison. If their health drops too low relative to the poison level, they will be stunned for %d turns."):format( eff.length)
      else
	 return ("The target is afflicted with a lethal poison. If their health drops too low relative to the poison level, they will be instantly killed."):format()
      end
   end,
   type = "other",
   subtype = { poison=true },
   status = "detrimental",
   parameters = {length=2, unresistable=true, threshold=1.0},
   on_timeout = function(self, eff) end,
   activate = function(self, eff) end,
   deactivate = function(self, eff)end,
   callbackOnTakeDamage = function(self, eff, src, x, y, type, dam, tmp)
      local new_life = self.life - dam
      local poison = 0
      for eff_id, p in pairs(self.tmp) do
	 local e = self.tempeffect_def[eff_id]
	 if e.subtype.poison and p.power then
	    poison = poison + p.power * p.dur
	 end
      end
      if new_life * eff.threshold <= poison then
	 self:setEffect(self.EFF_REK_WYRMIC_TOXIC_SHOCK, eff.length, {src=eff.src})
	 if self:canBe("instakill") and self.rank < 3 then
	    self:die(eff.src)
	 end
      end
      
      return {dam=dam}
   end,
}


newEffect{
	name = "REK_WYRMIC_VENOM", image = "talents/rek_wyrmic_venm.png",
	desc = "Deadly Venom",
	long_desc = function(self, eff)
		local crippling = eff.crippling > 0 and (" %d%% chance to fail talents."):format(eff.crippling) or ""
		return ("The target is poisoned, taking %0.2f nature damage per turn.%s"):format(eff.power, crippling) 
	end,
	charges = function(self, eff) return (math.floor(eff.power)) end,
	type = "physical",
   subtype = { poison=true, nature=true }, no_ct_effect = true,
   status = "detrimental",
   parameters = {power=10, reduce=5, criptime=0},
   on_gain = function(self, err) return "#Target# is poisoned!", "+Deadly Venom" end,
   on_lose = function(self, err) return "#Target# is no longer poisoned.", "-Deadly Venom" end,
   -- Damage each turn
   on_timeout = function(self, eff)
		 if self:attr("purify_poison") then 
			 self:heal(eff.power, eff.src)
		 elseif self.x and self.y then
			 local dam = DamageType:get(DamageType.NATURE).projector(eff.src, self.x, self.y, DamageType.NATURE, eff.power)
		 end
		 -- Cripple duration is tracked within the effect so that 1 cleanse removes it all.
		 if eff.criptime > 0 then
			 eff.criptime = eff.criptime - 1
			 if eff.criptime <= 0 then
				 self:removeTemporaryValue("talent_fail_chance", eff.cripid)
				 eff.cripid = null
				 eff.crippling = 0
				 game.logSeen(self, "%s is free from the venom's crippling power!", self.name:capitalize())
			 end
		 end
   end,
   on_merge = function(self, old_eff, new_eff) --Note: on_merge called before activate
		 -- Merge the poison
		 local olddam = old_eff.power * old_eff.dur
		 local newdam = new_eff.power * new_eff.dur
		 local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		 old_eff.dur = dur
		 old_eff.power = (olddam + newdam) / dur
		 -- by default, can stack up to 5x power
		 old_eff.max_power = math.max(old_eff.max_power or old_eff.power*5, new_eff.max_power or new_eff.power*5)
		 old_eff.power = math.min(old_eff.power, old_eff.max_power)
		 
		 if new_eff.crippling > 0 then
			 old_eff.criptime = math.max(old_eff.criptime, new_eff.dur)
		 end
		 if old_eff.cripid and new_eff.crippling > old_eff.cripid then
			 -- If a stronger cripple effect comes in, replace it.
			 self:removeTemporaryValue("talent_fail_chance", old_eff.cripid) 
			 old_eff.cripid = null
			 old_eff.cripid = self:addTemporaryValue("talent_fail_chance", new_eff.crippling)
		 elseif not old_eff.cripid and new_eff.crippling > 0  then
			 -- If a cripple is added to a non-crippling instance
			 old_eff.cripid = self:addTemporaryValue("talent_fail_chance", new_eff.crippling)
			 old_eff.crippling = new_eff.crippling
			 game.logSeen(self, "%s is crippled by the venom!", self.name:capitalize())
		 end
		 return old_eff
   end,
   activate = function(self, eff)
		 if eff.crippling > 0 then
			 eff.cripid = self:addTemporaryValue("talent_fail_chance", eff.crippling)
		 else
			 eff.cripid = nil
		 end
   end,
   deactivate = function(self, eff)
		 if eff.cripid then self:removeTemporaryValue("talent_fail_chance", eff.cripid) end
   end,
}

newEffect{
   name = "REK_WYRMIC_DOOM", image = "talents/impending_doom.png",
   desc = "Doomed",
   long_desc = function(self, eff) return ("You are cursed by dark magic, reducing healing by %d%%."):format(eff.healFactorChange*-100) end,
   type = "magicl",
   subtype = { curse=true }, no_ct_effect = true,
   status = "detrimental",
   parameters = { healFactorChange=-0.5 },
   on_gain = function(self, err) return "#Target# is doomed to die!", "+Doom" end,
   on_lose = function(self, err) return "#Target#'s doom has lifted.", "-Doom" end,
   activate = function(self, eff)
      eff.healFactorId = self:addTemporaryValue("healing_factor", eff.healFactorChange)
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("healing_factor", eff.healFactorId)
   end,
   on_merge = function(self, old_eff, new_eff)
      -- add the remaining healing reduction spread out over the new duration
      old_eff.healFactorChange = math.max(-0.75, (old_eff.healFactorChange / old_eff.totalDuration) * old_eff.dur + new_eff.healFactorChange)
      old_eff.dur = math.max(old_eff.dur, new_eff.dur)
      
      self:removeTemporaryValue("healing_factor", old_eff.healFactorId)
      old_eff.healFactorId = self:addTemporaryValue("healing_factor", old_eff.healFactorChange)
      game.logSeen(self, "%s's doom has returned!", self.name:capitalize())
      
      return old_eff
   end,
         }

newEffect{
   name = "REK_WYRMIC_PRISMATIC_SPEED",
   desc = "Speed", image = "talents/rek_wyrmic_multicolor_blood.png",
   long_desc = function(self, eff) return ("Action speed is increased by %d%%."):format(eff.power*100) end,
   type = "physical",
   subtype = { nature=true, speed=true },
   status = "beneficial",
   parameters = {power = 2},
   on_gain = function(self, err) return nil, "+Quick action" end,
   on_lose = function(self, err) return nil, "-Quick action" end,
   activate = function(self, eff)
      eff.cid = self:addTemporaryValue("combat_physspeed", eff.power)
      eff.mid = self:addTemporaryValue("combat_mindspeed", eff.power)
      eff.sid = self:addTemporaryValue("combat_spellspeed", eff.power)
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("combat_physspeed", eff.cid)
      self:removeTemporaryValue("combat_mindspeed", eff.mid)
      self:removeTemporaryValue("combat_spellspeed", eff.sid)
   end,
         }

newEffect{
   name = "REK_WYRMIC_PRISMATIC_BURST",
   desc = "Prismatic Burst", image = "talents/rek_wyrmic_prismatic_burst.png",
   long_desc = function(self, eff) return ("About to unleash a chaotic elemental attack"):format() end,
   type = "physical",
   subtype = { nature=true, fire=true, cold=true, lightning=true, physical=true, acid=true },
   status = "beneficial",
   parameters = {power = 20},
   callbackOnDealDamage = function(self, eff, val, target, dead, death_note)
      local x, y = target.x, target.y
      if not target or not self:canProject(target, x, y) then return nil end
      self:removeEffect(self.EFF_REK_WYRMIC_PRISMATIC_BURST)

      local aspects = self:callTalent(self.T_REK_WYRMIC_MULTICOLOR_BLOOD, "getOptions") or {
         {
	    name="Default Fire",
	    nameStatus="None",
	    nameDrake=(DamageType:get(DamageType.PHYSICAL) or "").text_color.."Generic Drake#LAST#",
	    damtype=DamageType.FIRE,
	    status=DamageType.FIRE,
	    talent=self.T_REK_WYRMIC_PRISMATIC_BURST
         }
                                                                                           }
      if aspects and #aspects > 0 then
	 local aspect = rng.table(aspects)
	 local nameBall = "rek_wyrmic_"..DamageType:get(aspect.damtype).name.."_ball"

	 local tg = {type="ball", range=10, selffire=false, friendlyfire=false, radius=eff.radius}
	 local grids = self:project(tg, x, y, aspect.status,
				    {
				       dam=self:mindCrit(eff.power),
				       dur=3,
				       chance=100,
				       daze=100,
				       fail=15
				    }
	 )
	 game.level.map:particleEmitter(x, y, tg.radius, nameBall, {radius=tg.radius, grids=grids, tx=x, ty=y, max_alpha=80})
	 game:playSoundNear(self, "talents/flame")
      end
   end,
   activate = function(self, eff)
   end,
   deactivate = function(self, eff)
   end,
         }

newEffect{
   name = "REK_WYRMIC_ELEMENT_EXPLOIT",
   desc = "Wyrmic Vulnerability", image = "talents/rek_wyrmic_element_exploit.png",
   long_desc = function(self, eff) return ("Takes extra damage from weapon attacks."):format() end,
   type = "other",
   subtype = { nature=true },
   status = "detrimental",
   parameters = {power = 0},
   activate = function(self, eff)
		 eff.particle = self:addParticles(Particles.new("circle", 1, {base_rot=1, oversize=1.0, a=200, appear=8, speed=0, img="rek_wyrmic_exploit_mark", radius=0}))
   end,
   deactivate = function(self, eff)
		 self:removeParticles(eff.particle)
   end,
}
