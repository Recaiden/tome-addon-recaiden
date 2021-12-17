local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "REK_MTYR_UNNERVE", image = "talents/rek_mtyr_unnerve.png",
	desc = _t"Unnerved",
	long_desc = function(self, eff) return ("Unable to handle the truth, giving them a %d chance to act randomly, suffering %d damage, and losing %d power, with a %d%% chance for longer cooldowns"):tformat(eff.power, eff.damage, eff.powerlessness, eff.pitilessness) end,
	type = "mental",
	subtype = { confusion=true, },
	status = "detrimental",
	parameters = { power = 20, damage=0, powerlessness=0, pitilessness=0 },
	
	activate = function(self, eff)
		eff.power = math.floor(util.bound(eff.power, 0, 50))
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
		
		if eff.powerlessness > 0 then
			eff.mental = self:addTemporaryValue("combat_mindpower", -eff.powerlessness)
			eff.spell = self:addTemporaryValue("combat_spellpower", -eff.powerlessness)
			eff.physical = self:addTemporaryValue("combat_dam", -eff.powerlessness)
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("confused", eff.tmpid)
		if eff.mental then
			self:removeTemporaryValue("combat_mindpower", eff.mental)
			self:removeTemporaryValue("combat_spellpower", eff.spell)
			self:removeTemporaryValue("combat_dam", eff.physical)
		end
		if self == game.player and self.updateMainShader then self:updateMainShader() end
	end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the best part of each effect
		local olddam = old_eff.damage * old_eff.dur
		local newdam = new_eff.damage * new_eff.dur
		old_eff.dur = new_eff.dur
		old_eff.damage = (olddam + newdam) / old_eff.dur
		old_eff.power = math.max(old_eff.power, new_eff.power)
		old_eff.powerlessness = math.max(old_eff.powerlessness, new_eff.powerlessness)
		old_eff.pitilessness = math.max(old_eff.pitilessness, new_eff.pitilessness)
		-- Clear the old debuffs
		if old_eff.mental then
			self:removeTemporaryValue("combat_mindpower", old_eff.mental)
			self:removeTemporaryValue("combat_spellpower", old_eff.spell)
			self:removeTemporaryValue("combat_dam", old_eff.physical)
		end
		self:removeTemporaryValue("confused", old_eff.tmpid)
		-- Add the new debuffs
		old_eff.power = math.floor(util.bound(old_eff.power, 0, 50))
		old_eff.tmpid = self:addTemporaryValue("confused", old_eff.power)
		if old_eff.powerlessness > 0 then
			old_eff.mental = self:addTemporaryValue("combat_mindpower", -old_eff.powerlessness)
			old_eff.spell = self:addTemporaryValue("combat_spellpower", -old_eff.powerlessness)
			old_eff.physical = self:addTemporaryValue("combat_dam", -old_eff.powerlessness)
		end
		return old_eff
	end,
	callbackOnAct = function(self, eff)
		if eff.src and eff.src:knowTalent(self.T_REK_MTYR_UNSETTLING_UNVEIL) and eff.src:getInsanity() <= 40 then
			if rng.percent(self:attr("confused")) then
				eff.src:incInsanity(1)
			end
		end
		if eff.pitilessness > 0 then
			local tids = {}
			for tid, lev in pairs(self.talents) do
				local t = self:getTalentFromId(tid)
				if t and self.talents_cd[tid] and not t.fixed_cooldown and rng.percent(eff.pitilessness) then tids[#tids+1] = t end
			end
			while #tids > 0 do
				local tt = rng.tableRemove(tids)
				if not tt then break end
				self.talents_cd[tt.id] = self.talents_cd[tt.id] + 1
			end
		end
	end,
	on_timeout = function(self, eff)
		if eff.damage > 0 then
			DamageType:get(DamageType.MIND).projector(eff.src, self.x, self.y, DamageType.MIND, eff.damage)
		end
	end,
}

newEffect{
   name = "REK_MTYR_JOLT_SHIELD", image = "talents/rek_mtyr_whispers_jolt.png",
   desc = _t"Recently Awakened",
   long_desc = function(self, eff) return ("Just woke up and is immune to all damage."):tformat() end,
   type = "other",
   subtype = { temporal=true },
   status = "beneficial",
   parameters = { power=100 },
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "cancel_damage_chance", 100)
   end,
   deactivate = function(self, eff)
   end,
   callbackOnActBase = function(self, t)
      self:removeEffect(self.EFF_REK_MTYR_JOLT_SHIELD)
   end,
}


newEffect{
	name = "REK_MTYR_SCORN", image = "talents/rek_mtyr_scourge_infest.png",
	desc = _t"Scorned",
	long_desc = function(self, eff)
		local damageTotal = 0
		for i, instance in pairs(eff.damage) do
			damageTotal = damageTotal + instance.power
		end
		return ("The target's self-image has been crushed, and they take %d damage each turn as a Disease effect%s %s %s"):tformat(damageTotal, eff.lifesteal > 0 and (" and heal the source for %d%% as much."):tformat(eff.lifesteal*100) or ".", eff.ramp > 1 and ("\nThe damage's intensity will increase by %d%% per turn."):tformat((eff.ramp-1)*100) or "", eff.fail > 0 and ("\nThe pain causes them to have a %d%% chance to fail to use talents."):tformat(eff.fail) or "")
	end,
	type = "mental",
	subtype = { disease=true, },
	status = "detrimental",
	parameters = { damage={{power=10, dur_m=0}}, ramp=1, lifesteal=0, fail=0},
	charges = function(self, eff)
		local damageTotal = 0
		for i, instance in pairs(eff.damage) do
			damageTotal = damageTotal + instance.power
		end
		return math.round(damageTotal)
	end,
	activate = function(self, eff)
		if eff.fail then
			eff.fail_id = self:addTemporaryValue("talent_fail_chance", eff.fail)
		end
	end,
	deactivate = function(self, eff)
		if eff.fail_id then
			self:removeTemporaryValue("talent_fail_chance", eff.fail_id)
		end
	end,
	on_merge = function(self, old_eff, new_eff)
		-- mark old damage instances to expire
		for i, instance in pairs(old_eff.damage) do
			old_eff.damage[i].dur_m = instance.dur_m + new_eff.dur - old_eff.dur
		end
		-- Merge the best part of each effect
		old_eff.dur = new_eff.dur
		old_eff.fail = math.max(old_eff.fail, new_eff.fail)
		old_eff.ramp = math.max(old_eff.ramp, new_eff.ramp)
		old_eff.lifesteal = math.max(old_eff.lifesteal, new_eff.lifesteal)
		-- add new damage instance
		old_eff.damage[#old_eff.damage+1] = new_eff.damage[1]
		
		-- Clear the old debuffs
		if old_eff.fail_id then
			self:removeTemporaryValue("talent_fail_chance", old_eff.fail_id)
		end
		-- Add the new debuffs
		if old_eff.fail then
			old_eff.fail_id = self:addTemporaryValue("talent_fail_chance", old_eff.fail)
		end	
		return old_eff
	end,
	on_timeout = function(self, eff)

		local damCurrent = 0
		for i, instance in pairs(eff.damage) do
			-- applications that have lived out their allotted time are cleared.
			if eff.dur < instance.dur_m then
				eff.damage[i].power = 0
			end

			-- Collect the damage
			if instance.power > 0 then
				if eff.src and eff.src:knowTalent(self.T_REK_MTYR_SCOURGE_SHARED_FEAST) and eff.src:getInsanity() >= 60 then
					--t2 insanity bonus
					damCurrent = damCurrent + instance.power * (1 + (eff.src:getInsanity()-50) / 100)
				else
					damCurrent = damCurrent + instance.power
				end
				-- increase each damage instance
				if eff.src and eff.src.x and eff.src.y and core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) <= 3 then
					eff.damage[i].power = instance.power * eff.ramp
				end
			end
		end

		-- Deal the damage
		if damCurrent > 0 then
			local realdam = DamageType:get(DamageType.MIND).projector(eff.src, self.x, self.y, DamageType.MIND, damCurrent, {from_disease=true})
			if eff.src and realdam > 0 and not eff.src:attr("dead") then
				eff.src:heal(realdam * eff.lifesteal, self)
			end
		end
	end,
}

newEffect{
   name = "REK_MTYR_INSPIRED", image = "talents/rek_mtyr_polarity_rebound.png",
   desc = _t"Inspired",
   long_desc = function(self, eff) return ("You are empowered by your madness, increasing  mindpower by %d."):tformat(eff.power * eff.stacks) end,
   type = "other",
   charges = function(self, eff) return eff.stacks end,
   subtype = { demented=true },
   status = "beneficial",
   parameters = { power=2, stacks=1, max_stacks=5 },
   on_merge = function(self, old_eff, new_eff)
      old_eff.dur = new_eff.dur
      old_eff.stacks = math.min(old_eff.stacks + new_eff.stacks, new_eff.max_stacks)
      old_eff.power = math.max(old_eff.power, new_eff.power)
      
      self:removeTemporaryValue("combat_mindpower", old_eff.mentalP)
      
      old_eff.mentalP = self:addTemporaryValue("combat_mindpower", old_eff.power*old_eff.stacks)
      
      return old_eff
   end,   
   activate = function(self, eff)
      eff.mentalP = self:addTemporaryValue("combat_mindpower", eff.power*eff.stacks)
   end,
   deactivate = function(self, eff)
      self:removeTemporaryValue("combat_mindpower", eff.mentalP)
   end,
}

newEffect{
   name = "REK_MTYR_DEMENTED", image = "talents/rek_mtyr_polarity_dement.png",
   desc = _t"Demented",
   long_desc = function(self, eff) return ("The target cannot think clearly, reducing their damage and increasing their cooldowns by %d%%."):tformat(eff.power*100) end,
   type = "mental",
   subtype = { demented=true },
   status = "detrimental",
   parameters = { power=0.1 },
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "numbed", eff.power*100)
      -- cooldown increase is in Actor.Lua
   end,
   deactivate = function(self, eff)
   end,
}

newEffect{
	name = "REK_MTYR_MANIC_SPEED", image = "talents/rek_mtyr_polarity_manic_speed.png",
	desc = _t"Manic Speed",
	long_desc = function(self, eff) return ("The target is moving at infinite speed for %d to %d steps."):tformat(eff.min_steps, eff.max_steps) end,
	type = "mental",
	charges = function(self, eff) return math.max(0, eff.min_steps - eff.steps) end,
	subtype = { haste=true },
	status = "beneficial",
	parameters = { min_steps=1, max_steps=8 },
	
	on_gain = function(self, err) return _t"#Target# accelerates out of sight!", _t"+Infinite Speed" end,
	on_lose = function(self, err) return _t"#Target# has lost their manic speed.", _t"-Infinite Speed" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "free_movement", 1)
		eff.steps = 0
		eff.ox = self.x
		eff.oy = self.y
	end,
	deactivate = function(self, eff)
		game:playSoundNear(self, "talents/rek_warp_off")
		if self:attr("defense_on_teleport") or self:attr("resist_all_on_teleport") or self:attr("effect_reduction_on_teleport") then
			self:setEffect(self.EFF_OUT_OF_PHASE, 4, {})
		end
		self:fireTalentCheck("callbackOnTeleport", true, eff.ox, eff.oy, self.x, self.y)
	end,
	callbackOnMove = function(self, eff, moved, force, ox, oy, x, y)
		if not moved then return end
		if force then return end
		if ox == self.x and oy == self.y then return end
		
		if self.reload then
			local reloaded = self:reload()
			if not reloaded and self.reloadQS then
				self:reloadQS()
			end
		end
		
		eff.steps = eff.steps + 1
		local remaining = eff.max_steps - eff.steps +1
		if eff.steps >= eff.max_steps or (eff.steps > eff.min_steps and rng.percent(100/remaining)) then
			self:removeEffect(self.EFF_REK_MTYR_MANIC_SPEED)	
		end
	end,
}

newEffect{
   name = "REK_MTYR_OVERSEER", image = "talents/rek_mtyr_vagabond_tainted_bullets.png",
   desc = _t"Psychic Tunneling",
   long_desc = function(self, eff) return ("Detects creatures of type %s/%s in radius 15."):tformat(eff.type, eff.subtype) end,
   type = "mental",
   subtype = { whisper=true },
   status = "beneficial",
   parameters = { type="humanoid", subtype="human" },
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "esp", {[eff.type.."/"..eff.subtype]=1})
      self:effectTemporaryValue(eff, "esp_range", 5)
   end,
   deactivate = function(self, eff)
   end,
         }

newEffect{
   name = "REK_FLAG_SYMBIOSIS", image = "talents/rek_mtyr_standard_symbiosis.png",
   desc = _t"Aura of Confidence",
   long_desc = function(self, eff) return ("Linked to their flag gaining %d%% all damage resistance."):tformat(eff.resist) end,
   type = "other",
   subtype = { miscellaneous=true },
   status = "beneficial",
   parameters = { resist=10, save=0 },
   on_gain = function(self, err) return _t"#Target# links closer to his ally!", true end,
   on_lose = function(self, err) return _t"#Target# no longer seems to be in sync with his ally.", true end,
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "resists", {all = eff.resist})
   end,
}


newEffect{
   name = "REK_MTYR_GUIDANCE_HEAL", image = "effects/rek_mtyr_whispers_guiding_light_heal.png",
   desc = _t"Guided to Healing",
   long_desc = function(self, eff)
      return ("A light of life shines upon the target, regenerating %0.2f life per turn."):tformat(eff.power)
   end,
   type = "physical",
   subtype = { healing=true, regeneration=true },
   status = "beneficial",
   parameters = { power=10, aura=0 },
   on_gain = function(self, err) return _t"#Target# is healing in the light.", _t"+Regen" end,
   on_lose = function(self, err) return _t"#Target# stops healing.", _t"-Regen" end,
   activate = function(self, eff)
      eff.tmpid = self:addTemporaryValue("life_regen", eff.power)   
      if core.shader.active(4) then
         eff.particle1 = self:addParticles(Particles.new("shader_shield", 1, {toback=true,  size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=2.0, circleColor={0,0,0,0}, beamsCount=9}))
         eff.particle2 = self:addParticles(Particles.new("shader_shield", 1, {toback=false, size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=1.0, circleColor={0,0,0,0}, beamsCount=9}))
      end
   end,
   on_timeout = function(self, eff)
      if self:knowTalent(self.T_ANCESTRAL_LIFE) then
         local t = self:getTalentFromId(self.T_ANCESTRAL_LIFE)
         self:incEquilibrium(-t.getEq(self, t))
      end
   end,
   deactivate = function(self, eff)
      self:removeParticles(eff.particle1)
      self:removeParticles(eff.particle2)
      self:removeTemporaryValue("life_regen", eff.tmpid)
   end,
         }

newEffect{
   name = "REK_MTYR_GUIDANCE_FLASH", image = "effects/rek_mtyr_whispers_guiding_light_eyes.png",
   desc = _t"Guided to Destroy",
   long_desc = function(self, eff) return ("The target's damage is improved by +%d%%."):tformat(eff.power) end,
   type = "mental",
   subtype = { focus=true },
   status = "beneficial",
   parameters = { power=10 },
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "inc_damage", {all = eff.power})
   end,
   deactivate = function(self, eff)
   end,
}

newEffect{
   name = "REK_MTYR_GUIDANCE_AVAILABLE", image = "talents/rek_mtyr_whispers_guiding_light.png",
   desc = _t"Seeking the Light",
   long_desc = function(self, eff) return ("Somewhere nearby is a beam of light this creature is looking for"):tformat() end,
   type = "other",
   subtype = { whisper=true },
   status = "beneficial",
   parameters = { ground_effect='' },
   activate = function(self, eff)
   end,
   deactivate = function(self, eff)
   end,
}


newEffect{
   name = "REK_MTYR_RESONATION", image = "talents/rek_mtyr_crucible_resonation.png",
   desc = _t"Runaway Resonation",
   long_desc = function(self, eff) return ("The target's subconscious is surging with energy, guaranteeing critical mental attacks and increasing critical power by +%d."):tformat(eff.power) end,
   type = "mental",
   subtype = { psionic=true },
   status = "beneficial",
   parameters = { power = 1 },
   on_gain = function(self, err) return _t"#Target#'s subconscious surges with power.", _t"+Resonation" end,
   on_lose = function(self, err) return _t"#Target#'s subconscious has returned to normal.", _t"-Resonation" end,
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "combat_mindcrit", 100)
      self:effectTemporaryValue(eff, "combat_critical_power", eff.power)
   end,
   on_timeout = function(self, eff)
   end,
}

newEffect{
   name = "REK_MTYR_SEVENFOLD_SPEED", image = "talents/rek_mtyr_revelation_speed.png",
   desc = _t"Writhing Speed",
   long_desc = function(self, eff) return ("The target's is making tentacle-assisted archery attacks very quickly."):tformat(eff.power) end,
   type = "mental",
   subtype = { physical=true },
   status = "beneficial",
   parameters = { power = 1, acc = 1 },
   activate = function(self, eff)
      self:effectTemporaryValue(eff, "combat_atk", eff.acc)
   end,
   on_timeout = function(self, eff)
   end,
}

newEffect{
	name = "REK_MTYR_MOMENT_COUNTER", image = "talents/rek_mtyr_moment_block.png",
	desc = _t"Cut Danger",
	long_desc = function(self, eff) return ("The target is countering all attacks, preventing %d damage."):tformat(eff.power) end,
	type = "other",
	subtype = { temporal=true, block=true },
	status = "beneficial",
	parameters = { power = 1, dam = 1.0 },
	activate = function(self, eff)
		--self:effectTemporaryValue(p, "flat_damage_armor", {all=eff.power})
	end,
	callbackOnTakeDamage = function(self, eff, src, x, y, type, dam, tmp)
		self.turn_procs.rek_martyr_moment_counter = self.turn_procs.rek_martyr_moment_counter or {}
		if src and src.x and src.y and src.life then
			if not self.turn_procs.rek_martyr_moment_counter[src.uid] then
				self.turn_procs.rek_martyr_moment_counter[src.uid] = true
				local t = self:getTalentFromId(self.T_REK_MTYR_MOMENT_BLOCK)
				if t and src ~= self then
					self:attackTargetWith(src, t.getFinalMoment(self, t), nil, eff.dam)
				end
      end
		end
			
		return {dam=math.max(0, dam-eff.power)}
	end,
}

newEffect{
   name = "REK_MTYR_MOMENT_WIELD", image = "talents/rek_mtyr_moment_stop.png",
   desc = _t"Cutting Fate",
   long_desc = function(self, eff) return ("The target is wielding the Final Moment as a sword."):tformat() end,
   type = "other",
   subtype = { temporal=true, weapon=true },
   status = "beneficial",
   parameters = { power=0 },
   activate = function(self, eff)
      self:effectParticles(eff, {type="circle", args={oversize=0, appear=12, base_rot=0, img="mtyr_clock_face", speed=0, radius=2}})
      self:effectParticles(eff, {type="circle", args={oversize=0, appear=12, img="mtyr_minute_hand", speed=3.6, radius=2}})
      self:effectParticles(eff, {type="circle", args={oversize=0, appear=12, img="mtyr_hour_hand", speed=0.3, radius=2}})
   end,
}


newEffect{
   name = "REK_MTYR_ABYSSAL_LUMINOUS", image = "talents/rek_mtyr_revelation_abyssal_shot.png",
   desc = _t"Abyssal Form: Luminous",
   long_desc = function(self, eff) return ("The target is revealed as a luminous horror!"):tformat() end,
   type = "other",
   subtype = { horror=true, morph=true },
   status = "detrimental",
   parameters = { talent_power=1 },
   on_gain = function(self, err) return "_t#PURPLE##Target# is revealed to have been a luminous horror all along!", true end,
   on_lose = function(self, err) return _t"#Target# returns to their normal guise.", true end,
   activate = function(self, eff)
      eff.allow_talent = {
         [self.T_CHANT_OF_FORTITUDE] = true,
         [self.T_SEARING_LIGHT] = true,
         [self.T_FIREBEAM] = true,
         [self.T_PROVIDENCE] = true,
         [self.T_HEALING_LIGHT] = true,
         [self.T_BARRIER] = true,
         [self.T_ATTACK] = true,
      }
      -- luminous passives
      self:effectTemporaryValue(eff, "resists", {[DamageType.LIGHT]=100, [DamageType.FIRE]=100, [DamageType.DARKNESS]=-50})
      self:effectTemporaryValue(eff, "damage_affinity", {[DamageType.LIGHT]=50, [DamageType.FIRE]=50})
      self:effectTemporaryValue(eff, "blind_immune", 1)

      -- luminous talents
      self:learnTalent(self.T_CHANT_OF_FORTITUDE, true, eff.talent_power)
      if not self:isTalentActive(self.T_CHANT_OF_FORTITUDE) then
         self:forceUseTalent(self.T_CHANT_OF_FORTITUDE, {ignore_energy=true})
      end
      self:learnTalent(self.T_SEARING_LIGHT, true, eff.talent_power)
      self:learnTalent(self.T_FIREBEAM, true, eff.talent_power)
      self:learnTalent(self.T_PROVIDENCE, true, eff.talent_power)
      self:learnTalent(self.T_HEALING_LIGHT, true, math.max(1, eff.talent_power-2))
      self:learnTalent(self.T_BARRIER, true, math.max(1, eff.talent_power-2))

      self:alterTalentCoolingdown(self.T_SEARING_LIGHT, -1000)
      self:alterTalentCoolingdown(self.T_FIREBEAM, -1000)
      self:alterTalentCoolingdown(self.T_PROVIDENCE, -1000)
      self:alterTalentCoolingdown(self.T_HEALING_LIGHT, -1000)
      self:alterTalentCoolingdown(self.T_BARRIER, -1000)
      self:incPositive(self:getMaxPositive())

      -- general horrifyingness
      eff.typeid = self.type
      self.type = "horror"
      self:project({type="ball", radius=10}, self.x, self.y, function(px, py)
                      local act = game.level.map(px, py, Map.ACTOR)
                      if not act or self:reactionToward(act) <= 0 then return end
                      if act == eff.src or act:resolveSource() == eff.src then return end  -- Pseudofaction to avoid anything directly linked to the effect source
                      act:setTarget(nil)
                                                             end)
      self:effectTemporaryValue(eff, "hated_by_everybody", 1)
      self.replace_display = mod.class.Actor.new{image="npc/horror_eldritch_luminous_horror.png",}
      self:removeAllMOs()
      game.level.map:updateMap(self.x, self.y)
   end,
   deactivate = function(self, eff)
      self.replace_display = nil
      self:removeAllMOs()
      game.level.map:updateMap(self.x, self.y)

      self.type = eff.typeid

      self:unlearnTalent(self.T_CHANT_OF_FORTITUDE, eff.talent_power)
      self:unlearnTalent(self.T_SEARING_LIGHT, eff.talent_power)
      self:unlearnTalent(self.T_FIREBEAM, eff.talent_power)
      self:unlearnTalent(self.T_PROVIDENCE, eff.talent_power)
      self:unlearnTalent(self.T_HEALING_LIGHT, math.max(1, eff.talent_power-2))
      self:unlearnTalent(self.T_BARRIER, math.max(1, eff.talent_power-2))
   end,
         }

newEffect{
   name = "REK_MTYR_ABYSSAL_UMBRAL", image = "talents/rek_mtyr_revelation_abyssal_shot.png",
   desc = _t"Abyssal Form: Umbral",
   long_desc = function(self, eff) return ("The target is revealed as an umbral horror!"):tformat() end,
   type = "other",
   subtype = { horror=true, morph=true },
   status = "detrimental",
   parameters = { talent_power=1 },
   on_gain = function(self, err) return _t"#PURPLE##Target# is revealed to have been an umbral horror all along!", true end,
   on_lose = function(self, err) return _t"#Target# returns to their normal guise.", true end,
   activate = function(self, eff)
      eff.allow_talent = {
         [self.T_CALL_SHADOWS] = true,
         [self.T_FOCUS_SHADOWS] = true,
         [self.T_SHADOW_WARRIORS] = true,
         [self.T_BLINDSIDE] = true,
         [self.T_DARK_TORRENT] = true,
         [self.T_CREEPING_DARKNESS] = true,
         [self.T_DARK_VISION] = true,
         [self.T_ATTACK] = true,
      }
      
      -- umbral passives
      self:effectTemporaryValue(eff, "resists", {[DamageType.DARKNESS]=100, [DamageType.LIGHT]=-50})
      self:effectTemporaryValue(eff, "combat_physspeed", 1.0)
      self:effectTemporaryValue(eff, "all_damage_convert", DamageType.DARKNESS)
      self:effectTemporaryValue(eff, "all_damage_convert_percent", 50)

      -- umbral talents
      self:learnTalent(self.T_CALL_SHADOWS, true, eff.talent_power)
      if not self:isTalentActive(self.T_CALL_SHADOWS) then
         self:forceUseTalent(self.T_CALL_SHADOWS, {ignore_energy=true})
      end
      self:learnTalent(self.T_FOCUS_SHADOWS, true, eff.talent_power)
      self:learnTalent(self.T_CREEPING_DARKNESS, true, eff.talent_power)
      self:learnTalent(self.T_DARK_VISION, true, eff.talent_power)
      self:learnTalent(self.T_DARK_TORRENT, true, eff.talent_power)
      self:learnTalent(self.T_BLINDSIDE, true, math.max(1, eff.talent_power-2))
      self:learnTalent(self.T_SHADOW_WARRIORS, true, math.max(1, eff.talent_power-2))

      self:alterTalentCoolingdown(self.T_FOCUS_SHADOWS, -1000)
      self:alterTalentCoolingdown(self.T_CREEPING_DARKNESS, -1000)
      self:alterTalentCoolingdown(self.T_DARK_TORRENT, -1000)
      self:alterTalentCoolingdown(self.T_BLINDSIDE, -1000)
      self:incHate(self:getMaxHate())

      -- general horrifyingness
      eff.typeid = self.type
      self.type = "horror"
      self:project({type="ball", radius=10}, self.x, self.y, function(px, py)
                      local act = game.level.map(px, py, Map.ACTOR)
                      if not act or self:reactionToward(act) <= 0 then return end
                      if act == eff.src or act:resolveSource() == eff.src then return end  -- Pseudofaction to avoid anything directly linked to the effect source
                      act:setTarget(nil)
                                                             end)
      self:effectTemporaryValue(eff, "hated_by_everybody", 1)
      self.replace_display = mod.class.Actor.new{image="npc/horror_eldritch_umbral_horror.png",}
      self:removeAllMOs()
      game.level.map:updateMap(self.x, self.y)
   end,
   deactivate = function(self, eff)
      self.replace_display = nil
      self:removeAllMOs()
      game.level.map:updateMap(self.x, self.y)

      self.type = eff.typeid

      self:unlearnTalent(self.T_FOCUS_SHADOWS, eff.talent_power)
      self:unlearnTalent(self.T_CREEPING_DARKNESS, eff.talent_power)
      self:unlearnTalent(self.T_SEARING_LIGHT, eff.talent_power)
      self:unlearnTalent(self.T_DARK_TORRENT, eff.talent_power)
      self:unlearnTalent(self.T_DARK_TORRENT, eff.talent_power)
      self:unlearnTalent(self.T_BLINDSIDE, math.max(1, eff.talent_power-2))
      self:unlearnTalent(self.T_SHADOW_WARRIORS, math.max(1, eff.talent_power-2))
   end,
}

newEffect{
   name = "REK_MTYR_ABYSSAL_BLOATED", image = "talents/rek_mtyr_revelation_abyssal_shot.png",
   desc = _t"Abyssal Form: Bloated",
   long_desc = function(self, eff) return ("The target is revealed as a bloated horror!"):tformat() end,
   type = "other",
   subtype = { horror=true, morph=true },
   status = "detrimental",
   parameters = { talent_power=1 },
   on_gain = function(self, err) return _t"#PURPLE##Target# is revealed to have been a bloated horror all along!", true end,
   on_lose = function(self, err) return _t"#Target# returns to their normal guise.", true end,
   activate = function(self, eff)
      eff.allow_talent = {
         [self.T_MIND_DISRUPTION] = true,
         [self.T_MIND_SEAR] = true,
         [self.T_TELEKINETIC_BLAST] = true,
         [self.T_ATTACK] = true,
      }
      -- bloated passives
      self:effectTemporaryValue(eff, "resists", {[DamageType.LIGHT]=-10})
      self:effectTemporaryValue(eff, "never_move", 1)
      self:effectTemporaryValue(eff, "levitation", 1)
      
      -- bloated talents
      self:learnTalent(self.T_MIND_DISRUPTION, true, eff.talent_power)
      self:learnTalent(self.T_MIND_SEAR, true, eff.talent_power)
      self:learnTalent(self.T_TELEKINETIC_BLAST, true, eff.talent_power)

      self:alterTalentCoolingdown(self.T_MIND_DISRUPTION, -1000)
      self:alterTalentCoolingdown(self.T_MIND_SEAR, -1000)
      self:alterTalentCoolingdown(self.T_TELEKINETIC_BLAST, -1000)
      self:incPsi(self:getMaxPsi())

      -- general horrifyingness
      eff.typeid = self.type
      self.type = "horror"
      self:project({type="ball", radius=10}, self.x, self.y, function(px, py)
                      local act = game.level.map(px, py, Map.ACTOR)
                      if not act or self:reactionToward(act) <= 0 then return end
                      if act == eff.src or act:resolveSource() == eff.src then return end
                      act:setTarget(nil)
                                                             end)
      self:effectTemporaryValue(eff, "hated_by_everybody", 1)
      self.replace_display = mod.class.Actor.new{image="npc/horror_eldritch_bloated_horror.png",}
      self:removeAllMOs()
      game.level.map:updateMap(self.x, self.y)
   end,
   deactivate = function(self, eff)
      self.replace_display = nil
      self:removeAllMOs()
      game.level.map:updateMap(self.x, self.y)

      self.type = eff.typeid

      self:unlearnTalent(self.T_MIND_DISRUPTION, eff.talent_power)
      self:unlearnTalent(self.T_MIND_SEAR, eff.talent_power)
      self:unlearnTalent(self.T_TELEKINETIC_BLAST, eff.talent_power)
   end,
}

newEffect{
   name = "REK_MTYR_ABYSSAL_PARASITIC", image = "talents/rek_mtyr_revelation_abyssal_shot.png",
   desc = _t"Abyssal Form: Parasitic",
   long_desc = function(self, eff) return ("The target is revealed as a Parasitic horror!"):tformat() end,
   type = "other",
   subtype = { horror=true, morph=true },
   status = "detrimental",
   parameters = { talent_power=1 },
   on_gain = function(self, err) return _t"#PURPLE##Target# is revealed to have been a Parasitic horror all along!", true end,
   on_lose = function(self, err) return _t"#Target# returns to their normal guise.", true end,
   activate = function(self, eff)
      eff.allow_talent = {
         [self.T_CRAWL_ACID] = true,
         [self.T_ACIDIC_SKIN] = true,
         [self.T_BLOOD_SPLASH] = true,
         [self.T_SWALLOW] = true,
         [self.T_ATTACK] = true,
      }
      -- Parasitic passives
      self:effectTemporaryValue(eff, "resists", {[DamageType.LIGHTNING] = -50, [DamageType.ACID] = 100, [DamageType.NATURE] = 50, [DamageType.BLIGHT] = 50})
      self:effectTemporaryValue(eff, "damage_affinity", {[DamageType.ACID]=50})
      self:effectTemporaryValue(eff, "movement_speed", 1.0)
      self:effectTemporaryValue(eff, "blind_immune", 1)

      -- Parasitic talents
      self:learnTalent(self.T_CRAWL_ACID, true, eff.talent_power)
      self:learnTalent(self.T_ACIDIC_SKIN, true, eff.talent_power)
      self:learnTalent(self.T_BLOOD_SPLASH, true, eff.talent_power)
      self:learnTalent(self.T_SWALLOW, true, eff.talent_power)

      self:learnTalent(self.T_ACIDIC_SKIN, true, eff.talent_power)
      if not self:isTalentActive(self.T_ACIDIC_SKIN) then
         self:forceUseTalent(self.T_ACIDIC_SKIN, {ignore_energy=true})
      end

      self:alterTalentCoolingdown(self.T_CRAWL_ACID, -1000)
      self:alterTalentCoolingdown(self.T_SWALLOW, -1000)

      -- general horrifyingness
      eff.typeid = self.type
      self.type = "horror"
      self:project({type="ball", radius=10}, self.x, self.y, function(px, py)
                      local act = game.level.map(px, py, Map.ACTOR)
                      if not act or self:reactionToward(act) <= 0 then return end
                      if act == eff.src or act:resolveSource() == eff.src then return end
                      act:setTarget(nil)
                                                             end)
      self:effectTemporaryValue(eff, "hated_by_everybody", 1)
      self.replace_display = mod.class.Actor.new{image="npc/horror_eldritch_parasitic_horror.png",}
      self:removeAllMOs()
      game.level.map:updateMap(self.x, self.y)
   end,
   deactivate = function(self, eff)
      self.replace_display = nil
      self:removeAllMOs()
      game.level.map:updateMap(self.x, self.y)

      self.type = eff.typeid

      self:unlearnTalent(self.T_CRAWL_ACID, eff.talent_power)
      self:unlearnTalent(self.T_ACIDIC_SKINR, eff.talent_power)
      self:unlearnTalent(self.T_BLOOD_SPLASH, eff.talent_power)
      self:unlearnTalent(self.T_SWALLOW, eff.talent_power)
   end,
         }


newEffect{
	name = "REK_MTYR_SANE", image = "effects/rek_mtyr_insanity_low.png",
	desc = _t"Sane",
	long_desc = function(self, eff) return ("You see the world as it truly is."):tformat(eff.slow, eff.armor) end,
	type = "other",
	subtype = { insanity=true },
	status = "beneficial",
	decrease = 0, no_player_remove = true,
	parameters = {thresh=60},
	callbackOnAct = function(self, eff)
		
		if self:getInsanity() >= eff.thresh then
			self:removeEffect(self.EFF_REK_MTYR_SANE)
			self:setEffect(self.EFF_REK_MTYR_INSANE, 1, {})
			
			--flag graphics
			if game.party and game.party:hasMember(self) then
				for flag, def in pairs(game.party.members) do
					if flag.is_tentacle_flag then
						flag.replace_display = mod.class.Actor.new{image="npc/rek_mtyr_banner.png",}
						flag:removeAllMOs()
						game.level.map:updateMap(flag.x, flag.y)
					end
				end
			end
		end
	end,
	activate = function(self, eff)
	end,   
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "REK_MTYR_INSANE", image = "effects/rek_mtyr_insanity_high.png",
	desc = _t"Insane",
	long_desc = function(self, eff) return "You see the world as it should be." end,
	type = "other",
	subtype = { insanity=true },
	status = "beneficial",
	decrease = 0, no_player_remove = true,
	parameters = {thresh=40},
	callbackOnAct = function(self, eff)
		if self:getInsanity() <= eff.thresh then
			self:removeEffect(self.EFF_REK_MTYR_INSANE)
			self:setEffect(self.EFF_REK_MTYR_SANE, 1, {})
			
			--flag graphics
			if game.party and game.party:hasMember(self) then
				for flag, def in pairs(game.party.members) do
					if flag.is_tentacle_flag then
						flag.replace_display = nil
						flag:removeAllMOs()
						game.level.map:updateMap(flag.x, flag.y)
					end
				end
			end
		end
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "MARTYR_STACKING_SLOW", image = "talents/rek_mtyr_vagabond_tainted_bullets.png",
	desc = _t"Tainted Rounds",
	long_desc = function(self, eff)
		local source = eff.src or self
		return ("Reduces movement speed by %d%% and deals %0.2f mind damge when a new stack is applied."):tformat(math.floor(eff.stacks * 10), source:damDesc("MIND", eff.power*eff.stacks))
	end,
	charges = function(self, eff) return (math.floor(eff.stacks * 10).."%") end,
	type = "physical",
	subtype = { disease=true, slow=true },
	status = "detrimental",
	parameters = { power=3, stacks=1, max_stacks=10 },
	on_gain = function(self, err) return _t"#Target# is slowed by the taint", _t"+Tainted Slow" end,
	on_lose = function(self, err) return _t"#Target# speeds up.", _t"-Tainted Slow" end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		old_eff.stacks = math.min(old_eff.stacks + new_eff.stacks, new_eff.max_stacks)
		DamageType:get(DamageType.MIND).projector(old_eff.src, self.x, self.y, DamageType.MIND, old_eff.power * old_eff.stacks)
		self:removeTemporaryValue("movement_speed", old_eff.speed)
		old_eff.speed = self:addTemporaryValue("movement_speed", -old_eff.stacks*0.1)
		return old_eff		
	end,
	activate = function(self, eff)
		eff.speed = self:addTemporaryValue("movement_speed", -eff.stacks*0.1)
		local dam = eff.power
		if eff.src and eff.src.mindCrit then dam = eff.src:mindCrit(dam) end
		DamageType:get(DamageType.MIND).projector(eff.src, self.x, self.y, DamageType.MIND, dam)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("movement_speed", eff.tmpid)
		self:setProc("martyr_unslowable", true, 5)
	end,
}
