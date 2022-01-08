local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "REK_HEKA_OCULATUS", image = "talents/rek_heka_intrusion_eye.png",
	desc = _t"Eye Shield",
	long_desc = function(self, eff) return ("The target grows and reduces all incoming damage by %d."):tformat(eff.power) end,
	type = "physical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { power=5 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("flat_damage_armor", { all = eff.power })
		self:effectTemporaryValue(eff, "size_category", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("flat_damage_armor", eff.tmpid)
	end,
}

newEffect{
	name = "REK_HEKA_CRAB_GRAB", image = "talents/rek_heka_intrusion_claw.png",
	desc = _t"Crab Grab",
	long_desc = function(self, eff) return _t"The target is pinned by a crab claw, unable to move and taking damage." end,
	type = "physical",
	subtype = { pin=true },
	status = "detrimental",
	parameters = {power = 5},
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("never_move", 1)

		if not self.add_displays then
			self.add_displays = { Entity.new{image='npc/bone_grab_pin.png', display=' ', display_on_seen=true } }
			eff.added_display = true
		end
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)
	end,
	deactivate = function(self, eff)
		if eff.added_display then self.add_displays = nil end
		self:removeAllMOs()
		game.level.map:updateMap(self.x, self.y)

		self:removeTemporaryValue("never_move", eff.tmpid)
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src or self, self.x, self.y, DamageType.PHYSICAL, eff.power)
	end,
}

newEffect{
	name = "REK_HEKA_FUSILLADE", image = "talents/rek_heka_intrusion_spider.png",
	desc = _t"Arachnofusillade",
	long_desc = function(self, eff) return ("Each turn, stab the ground, causing 2 random explosions doing %0.1f physical damage in radius 1."):tformat(eff.dam) end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { dam=10 },
	on_gain = function(self, err) return _t"#Target# begins stabbing wildly through a breach in reality!", _t"+Intrusion" end,
	on_lose = function(self, err) return _t"The breach around #Target# seals itself.", _t"-Intrusion" end,
	on_timeout = function(self, eff)
		if game.zone.short_name.."-"..game.level.level ~= eff.level then return end

		for i=1, 2 do
			local spot = rng.table(eff.list)
			if not spot or not spot.x then return end
			self:project({type="ball", x=spot.x, y=spot.y, radius=1, selffire=self:spellFriendlyFire()}, spot.x, spot.y, DamageType.REK_HEKA_PHYSICAL_STUN, self:spellCrit(eff.dam))
			game.level.map:particleEmitter(spot.x, spot.y, 2, "generic_sploom", {rm=150, rM=180, gm=150, gM=180, bm=150, bM=180, am=80, aM=150, radius=1, basenb=120})
		end
		game:playSoundNear(self, "talents/arcane")
	end,
	on_merge = function(self, old_eff, new_eff)
		new_eff.dur = new_eff.dur + old_eff.dur
		if old_eff.particle then game.level.map:removeParticleEmitter(old_eff.particle) end
		new_eff.particle = Particles.new("circle", new_eff.radius, {a=150, speed=0.15, img="aether_breach", radius=new_eff.radius})
		new_eff.particle.zdepth = 6
		game.level.map:addParticleEmitter(new_eff.particle, new_eff.x, new_eff.y)		
		return new_eff
	end,
	activate = function(self, eff)
		eff.particle = Particles.new("circle", eff.radius, {a=150, speed=0.15, img="aether_breach", radius=eff.radius})
		eff.particle.zdepth = 6
		game.level.map:addParticleEmitter(eff.particle, eff.x, eff.y)

		local spot = {x=eff.x, y=eff.y}
		self:project({type="ball", x=spot.x, y=spot.y, radius=1, selffire=self:spellFriendlyFire()}, spot.x, spot.y, DamageType.REK_HEKA_PHYSICAL_STUN, self:spellCrit(eff.dam))
		game.level.map:particleEmitter(spot.x, spot.y, 2, "generic_sploom", {rm=150, rM=180, gm=150, gM=180, bm=150, bM=180, am=80, aM=150, radius=1, basenb=120})
	end,
	deactivate = function(self, eff)
		if game.zone.short_name.."-"..game.level.level ~= eff.level then return end
		game.level.map:removeParticleEmitter(eff.particle)
	end,
}

newEffect{
	name = "REK_HEKA_SPEARED", image = "talents/rek_heka_intrusion_hellyfish.png",
	desc = _t"Numbed",
	long_desc = function(self, eff) return ("The target is weakened by painful stinging, all damage it does is reduced by %d%%."):tformat(eff.power) end,
	type = "physical",
	subtype = { hands=true,},
	status = "detrimental",
	parameters = {power=10},
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("numbed", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("numbed", eff.tmpid)
	end,
}

newEffect{
	name = "REK_HEKA_LULLABY", image = "talents/rek_heka_oceansong_fail.png",
	desc = _t"Confounding Lullaby",
	long_desc = function(self, eff) return ("The target can't think straight, causing their actions to fail %d%% of the time."):tformat(eff.power) end,
	type = "other",
	subtype = { sound=true },
	status = "detrimental",
	parameters = {},
	activate = function(self, eff) self:effectTemporaryValue(eff, "talent_fail_chance", eff.power) end,
	deactivate = function(self, eff) end,
}

newEffect{
	name = "REK_HEKA_HAND_REGEN", image = "talents/rek_heka_page_regen.png",
	desc = _t"Carnigenesis",
	long_desc = function(self, eff) return ("This creature is rapidly gaining hands."):tformat() end,
	type = "physical",
	subtype = { hands=true },
	status = "beneficial",
	parameters = { hands=5, power=5 },
	activate = function(self, eff)
		eff.hands_base = eff.hands
		self:effectTemporaryValue(eff, "combat_spellpower", eff.power)
		eff.hid = self:addTemporaryValue("hands_regen", eff.hands)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("hands_regen", eff.hid)
	end,
	on_timeout = function(self, eff)
		self:removeTemporaryValue("hands_regen", eff.hid)
		eff.hands = eff.hands + eff.hands_base
		eff.hid = self:addTemporaryValue("hands_regen", eff.hands)
	end,
}

newEffect{
	name = "REK_HEKA_PHASE_OUT", image = "talents/rek_heka_page_flip.png",
	desc = _t"Total Phase Shift",
	long_desc = function(self, eff) return ("Sealed away into the warped realm of a kharybdian, unable to act but completely invulnerable."):tformat() end,
	type = "magical",
	subtype = { warp=true, time=true },
	status = "detrimental",
	parameters = { },
	tick_on_timeless = true,
	on_gain = function(self, err) return _t"#Target# is drawn into the other place!", _t"+Phase Shift" end,
	on_lose = function(self, err) return _t"#Target# returns to normal space.", _t"-Phase Shift" end,
	activate = function(self, eff)
		eff.iid = self:addTemporaryValue("invulnerable", 1)
		eff.sid = self:addTemporaryValue("time_prison", 1)
		eff.tid = self:addTemporaryValue("no_timeflow", 1)
		eff.imid = self:addTemporaryValue("status_effect_immune", 1)
		if core.shader.active() then
			self:effectParticles(eff, {type="shader_shield", args={toback=true,  size_factor=1, img="heka_phase_shift"}, shader={type="rotatingshield", noup=2.0, cylinderRotationSpeed=1.7, appearTime=0.2}})
			self:effectParticles(eff, {type="shader_shield", args={toback=false, size_factor=1, img="heka_phase_shift"}, shader={type="rotatingshield", noup=1.0, cylinderRotationSpeed=1.7, appearTime=0.2}})
		else
			self:effectParticles(eff, {type="time_prison", args={}})
		end
		self.energy.value = 0
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("invulnerable", eff.iid)
		self:removeTemporaryValue("time_prison", eff.sid)
		self:removeTemporaryValue("no_timeflow", eff.tid)
		self:removeTemporaryValue("status_effect_immune", eff.imid)
	end,
	on_timeout = function(self, eff)
		-- Reduce cooldowns
		for tid, _ in pairs(self.talents_cd) do
			local t = self:getTalentFromId(tid)
			if t and tid ~= self.T_REK_HEKA_PAGE_FLIP then
				if not t.fixed_cooldown then
					self.talents_cd[tid] = self.talents_cd[tid] - 2
				else
					self.talents_cd[tid] = self.talents_cd[tid] - 1
				end
			end
		end
	end,
}

newEffect{
	name = "REK_HEKA_TEMPO", image = "talents/rek_heka_bloodtide_buff.png",
	desc = _t"Tidal Tempo",
	long_desc = function(self, eff)
		local str = ("Ready to cast a spell for increased damage | "):tformat(eff.stacks)
		for tid, time in pairs(eff.talents) do
			if time > 0 then
				local t = self:getTalentFromId(tid)
				str = str..(" %s |"):tformat(t.name)
			end
		end
		return str
	end,
	type = "other",
	subtype = { hands=true },
	status = "beneficial",
	parameters = { talents = {} },
	on_merge = function(self, old_eff, new_eff, e)
		old_eff.dur = new_eff.dur
		table.merge(old_eff.talents, new_eff.talents)
		return old_eff
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		for tid, time in pairs(eff.talents) do
			eff.talents[tid] = time - 1
			if time - 1 <= 0 then
				eff.talents[tid] = nil
			end
		end
	end,
}

newEffect{
	name = "REK_HEKA_RECURRING_VISIONS", image = "talents/rek_heka_chronorium_visions.png",
	desc = _t"Recurring Visions",
	long_desc = function(self, eff) return ([[%0.1f damage from the past will be taken in the future.]]):tformat(eff.power) end,
	type = "other",
	subtype = { temporal=true },
	status = "detrimental",
	parameters = { power=0, thresh=10, ratio=0.3 },
	on_merge = function(self, old_eff, new_eff, e)
		old_eff.dur = new_eff.dur
		old_eff.power = old_eff.power + new_eff.power
		return old_eff
	end,
	activate = function(self, eff) end,
	deactivate = function(self, eff) end,
	callbackOnDeath = function(self, eff)
		self:removeEffect(self.EFF_REK_HEKA_RECURRING_VISIONS, true, true)
	end,
	callbackOnActEnd = function(self, eff)
		game:onTickEnd(function() 
				local rest = self.resting
				if self.resists and self.resists.absolute then
					eff.power = eff.power * ((100 - math.min(self.resists_cap.absolute or 70, self.resists.absolute)) / 100)
				end
				local reserved = 0
				if eff.power > eff.thresh then
					reserved = math.min(eff.power - eff.thresh, eff.power * eff.ratio)
					eff.power = eff.power - reserved
				end
				
				game:delayedLogDamage(self, self, 0, ("#WHITE#%d#LAST#"):format(eff.power), false)
				--game.logSeen(self, "%s takes %0.1f damage from the past.",self:getName():capitalize(), eff.power)
				self:takeHit(eff.power, self)
				eff.power = reserved
				if eff.power > 0 then
					eff.dur = eff.dur + 1
				end
		end)
	end,
}

newEffect{
	name = "REK_HEKA_POLYP", image = "talents/rek_heka_polyp_polyp.png",
	desc = _t"Polyp Anchor",
	long_desc = function(self, eff) return ("The target is infected with larval polyps.  Each turn it will suffer %0.1f blight damage.\nAfter three turns the effect will inflict %0.1f physical damage and become a polyp summon."):tformat(eff.dam, eff.damEnd) end,
	type = "magical",
	subtype = { blight=true, disease=true },
	status = "detrimental",
	parameters = { dam=5, damEnd=10, count=3, spreadAmp=1.0, spreadRange=0 },
	activate = function(self, eff)
		eff.spreadable = false
		eff.particle = self:addParticles(Particles.new("circle", 1, {base_rot=0, oversize=0.7, a=255, appear=8, speed=0, img="blight_polyps", radius=0}))
	end,
	callbackOnDispelled = function(self, eff, type, effid_or_tid, src, allow_immunity)
		if effid_or_tid ~= self.EFF_REK_HEKA_POLYP then return end
		eff.spawned = true
	end,
	summon = function(self, eff)
		if eff.spawned then return end
			
		eff.src:callTalent(eff.src.T_REK_HEKA_POLYP_POLYP, "summon", self)		
		game.logSeen(self, "#LIGHT_RED#An otherworldly polyp bursts out of %s!", self:getName():capitalize())
		eff.spawned = true
		self:removeEffect(self.EFF_REK_HEKA_POLYP)
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src, self.x, self.y, DamageType.PHYSICAL, eff.damEnd, {from_disease=true})
		local ed = self:getEffectFromId(eff.effect_id)
		ed.summon(self, eff)
	end,
	callbackOnDeath = function(self, eff)
		local ed = self:getEffectFromId(eff.effect_id)
		ed.summon(self, eff)
	end,
	on_timeout = function(self, eff)
		if self:attr("purify_disease") then self:heal(eff.dam, eff.src)
		else
			local tg = {type="ball", range=0, selffire=false, radius=eff.spreadRange}
			local hit = false
			if eff.spreadable then
				self:project(tg, self.x, self.y, function(px, py)
											 local target = game.level.map(px, py, Map.ACTOR)
											 if not target then return end
											 if self:reactionToward(target) >= 0 then
												 if not target:hasEffect(target.EFF_REK_HEKA_POLYP) then
													 hit = true
													 target:setEffect(target.EFF_REK_HEKA_POLYP, eff.dur, {src=eff.src, apply_power=(eff.src and eff.src:combatSpellpower() or self:combatSpellpower()), dam=eff.dam, damEnd=eff.damEnd})
												 end
											 end
				end)
			else
				hit = true
				eff.spreadable = true
			end
			if not hit then eff.dam = eff.dam * eff.spreadAmp end
			DamageType:get(DamageType.BLIGHT).projector(eff.src, self.x, self.y, DamageType.BLIGHT, eff.dam, {from_disease=true})
		end
	end,
}

newEffect{
	name = "REK_HEKA_RESERVOIR", image = "talents/rek_heka_moonwurm_reservoir.png",
	desc = _t"Reservoir",
	long_desc = function(self, eff) return ("%d life is saved to revive you."):tformat(eff.power) end,
	type = "other",
	subtype = { hands=true },
	status = "beneficial",
	no_remove = true,
	decrease = 0,
	charges = function(self, eff)
		return eff.power >= eff.max and "Max" or math.floor(eff.power)
		--return ([[%d/%d]]):format(eff.power, eff.max)
	end,
	charges_smallfont = true,
	parameters = { power = 0, max = 100 },
	on_merge = function(self, old_eff, new_eff)
		old_eff.max = new_eff.max
		old_eff.power = old_eff.power + new_eff.power
		return old_eff
	end,
	activate = function(self, eff) end,
	deactivate = function(self, eff) end,
	callbackPriorities = {callbackOnTakeDamage = 10}, --higher (later) than hand talents
	callbackOnTakeDamage = function(self, eff, src, x, y, type, dam, state, no_martyr)
		if dam < self.life + (self.die_at or 0) then return nil end
		self:heal(eff.power)

		if eff.src:knowTalent(eff.src.T_REK_HEKA_MOONWURM_SUMMON) then
			eff.src:callTalent(eff.src.T_REK_HEKA_MOONWURM_SUMMON, "summon", self.x, self.y)
		end

		self:removeEffect(self.EFF_REK_HEKA_RESERVOIR, true, true)
		return {dam=0, stopped=true}
	end,
}

newEffect{
	name = "REK_HEKA_WURMDISTRACTION", image = "talents/rek_heka_moonwurn_distraction.png",
	desc = _t"Distracted",
	long_desc = function(self, eff) return ("Taking %d%% more dmaage from all sources."):tformat(eff.power*100) end,
	type = "other",
	subtype = { hands=true },
	status = "detrimental",
	charges = function(self, eff)
		return ([[%d%%]]):format(eff.power*100)
	end,
	parameters = { power = 0.0 },
	activate = function(self, eff) end,
	deactivate = function(self, eff) end,
	callbackOnTakeDamage = function(self, eff, src, x, y, type, dam, state)
		return {dam=dam*(1+eff.power)}
	end,
}

newEffect{
	name = "REK_HEKA_WITHERED_RESISTANCES", image = "talents/rek_heka_vizier_sun.png",
	desc = _t"Withered",
	long_desc = function(self, eff) return ("The target's resistances have been reduced by %d%%."):tformat(eff.power) end,
	type = "other",
	subtype = { light=true },
	status = "detrimental",
	parameters = { power=5, max_power=5 },
	charges = function(self, eff) return eff.power end,
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("resists", old_eff.tmpid)

		new_eff.max_power = math.max(new_eff.max_power, old_eff.max_power)
		new_eff.power = math.min(new_eff.max_power, old_eff.power+new_eff.power)
		new_eff.tmpid = self:addTemporaryValue("resists", {all = -new_eff.power})
		return new_eff
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("resists", {all = -eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "REK_HEKA_SALTED", image = "talents/rek_heka_march_salt.png",
	desc = _t"Salted",
	long_desc = function(self, eff) return _t"The target has been encased in salt: it is rooted in place and may be shattered by a single blow dealing more than 30% of its maximum life." end,
	type = "magical",
	subtype = { earth=true, stone=true, stun = true},
	status = "detrimental",
	parameters = {},
	callbackPriorities = {callbackOnHit = 210},
	callbackOnHit = function(self, eff, cb, src, death_note)
		if cb.value <= 0 then return cb end
		if cb.value >= self.max_life * 0.3 then
		-- Make the damage high enough to kill it
			cb.value = self.max_life + (self.die_at or 1) +1
			game.logSeen(self, "%s crumbles into grains of salt!", self:getName():capitalize())
		end
		return cb
	end,
	activate = function(self, eff)
		eff.never_move = self:addTemporaryValue("never_move", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.never_move)
	end,
}

newEffect{
	name = "REK_HEKA_UNBLEEDING_HEART", image = "talents/rek_heka_march_heart.png",
	desc = _t"Unbleeding Heart",
	long_desc = function(self, eff) return _t"The target's main heart has manifested on the battlefield to attack." end,
	type = "magical",
	subtype = { hands=true },
	status = "beneficial",
	parameters = {power=6},
	callbackOnCrit = function(self, eff, crit_type, damage, chance, target)
		eff.src:callTalent(eff.src.T_REK_HEKA_MARCH_HEART, "doSpike", eff.power)
	end,
	on_timeout = function(self, eff)
		eff.src:callTalent(eff.src.T_REK_HEKA_MARCH_HEART, "doSpike", eff.power)
	end,
	activate = function(self, eff)
		eff.src:callTalent(eff.src.T_REK_HEKA_MARCH_HEART, "doSpike", eff.power)
		eff.particle = self:addParticles(Particles.new("circle", 1, {base_rot=0, oversize=0.3, y=-0.68, a=255, appear=8, speed=0, img="sea_heart", radius=0}))
	end,
	deactivate = function(self, eff) self:removeParticles(eff.particle) end,
}

newEffect{
	name = "REK_HEKA_LINGERING_DESTRUCTION", image = "talents/rek_heka_march_destruction.png",
	desc = "Power from Destruction",
	long_desc = function(self, eff) return ("Increased spellpower by %d"):format(eff.power) end,
	type = "physical",
	subtype = { hands=true, arcane = true },
	status = "beneficial",
	parameters = { power=1, max_power=100},
	charges = function(self, eff) return eff.power end,
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("combat_spellpower", old_eff.pid)
		new_eff.power = math.min(new_eff.max_power, old_eff.power+new_eff.power)
		new_eff.pid = self:addTemporaryValue("combat_spellpower", new_eff.power)
		return new_eff
	end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("combat_spellpower", eff.power)
	end,
	deactivate = function(self, eff)
	end,
}
