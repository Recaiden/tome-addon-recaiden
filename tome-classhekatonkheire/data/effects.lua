local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Shader = require "engine.Shader"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"

newEffect{
	name = "REK_HEKA_SUNDERED_RESISTANCES", image = "talents/rek_heka_titanic_sunder.png",
	desc = _t"Sundered",
	long_desc = function(self, eff) return ("The target's resistances have been reduced by %d%%."):tformat(eff.power) end,
	type = "physical",
	subtype = { wound=true },
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("resists", {
			all = -eff.power,
		})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
	end,
}

newEffect{
	name = "REK_HEKA_TOWERING_WRATH", image = "talents/rek_heka_shambler_towering_wrath.png",
	desc = _t"Towering Wrath",
	long_desc = function(self, eff) return ("This creature is winding up a massive attack that does %0.2fx damage."):tformat(1+eff.power*eff.stacks) end,
	charges = function(self, eff) return eff.stacks end,
	type = "physical",
	subtype = { might=true },
	status = "beneficial",
	parameters = { power=0.5, stacks=1, max_stacks=3 },
	on_merge = function(self, old_eff, new_eff, e)
		self:removeTemporaryValue("size_category", old_eff.sizeid)
		self:removeParticles(old_eff.particle)
		new_eff.stacks = util.bound(old_eff.stacks + 1, 1, new_eff.max_stacks)
		new_eff.sizeid = self:addTemporaryValue("size_category", 1)
		new_eff.particle = self:addParticles(Particles.new("otherside_rising_sparks", 1, {base_rot=0,  a=235, appear=12, y=self.y, nb=new_eff.stacks}))
		return new_eff
	end,
	activate = function(self, eff)
		eff.sizeid = self:addTemporaryValue("size_category", 1)
		eff.particle = self:addParticles(Particles.new("otherside_rising_sparks", 1, {base_rot=0,  a=235, appear=12, y=self.y}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		game:onTickEnd(function()
										 self:removeTemporaryValue("size_category", eff.sizeid)
									 end)
	end,
}

newEffect{
	name = "REK_HEKA_METAFOLD", image = "talents/rek_heka_shambler_towering_wrath.png",
	desc = _t"Metafold",
	long_desc = function(self, eff) return ("This creature is revealed as a massive extradimensional horror"):tformat() end,
	type = "magical",
	subtype = { might=true, warp=true },
	status = "beneficial",
	parameters = { power=2 },
	activate = function(self, eff)
		eff.sizeid = self:addTemporaryValue("size_category", eff.power)
		self:addShaderAura("rek_heka_metafolded", "awesomeaura", {time_factor=16000, alpha=0.9}, "particles_images/metafolded.png")
	end,
	deactivate = function(self, eff)
		self:removeShaderAura("rek_heka_metafolded")
		self:removeTemporaryValue("size_category", eff.sizeid)
	end,
}

newEffect{
	name = "REK_HEKA_ARM_PORTAL", image = "talents/rek_heka_splinter_arms.png",
	desc = _t"Divided Arms",
	long_desc = function(self, eff) return ("Making attacks remotely."):tformat(eff.resist, eff.numb, eff.dam) end,
	type = "other",
	subtype = { warp=true },
	status = "beneficial",
	parameters = { interval=5 },
	activate = function(self, eff)
		eff.timer = eff.interval
		eff.particles = Particles.new("meleestorm_constant", 1, {})
		eff.particles.x = eff.x
		eff.particles.y = eff.y
		game.level.map:addParticleEmitter(eff.particles)
	end,
	deactivate = function(self, eff)
		if eff.particles then
			game.level.map:removeParticleEmitter(eff.particles)
		end
	end,
	on_timeout = function(self, eff)
		eff.timer = eff.timer - 1
		if not eff.x or not eff.y then return end
		if eff.timer <= 0 and self:hasLOS(eff.x, eff.y) then
			-- do attacks
			local ox, oy = self.x, self.y
			local power, stacks, dur = nil, nil, nil
			local oeff = self:hasEffect(self.EFF_REK_HEKA_TOWERING_WRATH)
			
			if oeff then
				power, stacks, dur  = oeff.power, oeff.stacks, oeff.dur
				self:removeEffect(self.EFF_REK_HEKA_TOWERING_WRATH)
			end
			
			local tg = {type="ball", range=0, selffire=false, radius=1}
			self.x, self.y = eff.x, eff.y
			self:project(
				tg, eff.x, eff.y,
				function(px, py, tg, self)
					local target = game.level.map(px, py, Map.ACTOR)
					if target and target ~= self and self:reactionToward(target) < 0 then
						self:attackTarget(target, nil, eff.mult or 1.0, true)
					end
				end)
			self.x, self.y = ox, oy
			if power then
				self:setEffect(self.EFF_REK_HEKA_TOWERING_WRATH, dur, {power=power, stacks=stacks, max_stacks=3, src=self})
			end
			
			eff.timer = eff.interval
		end
	end,
}

newEffect{
	name = "REK_HEKA_MAGPIE_WEAPONS", image = "talents/rek_heka_helping_magpie.png",
	desc = _t"Magpie Weapon",
	long_desc = function(self, eff) return ("This creature is ready to attack with a stolen weapon for %d%% damage."):tformat(eff.mult*100) end,
	type = "physical",
	subtype = { might=true },
	status = "beneficial",
	parameters = { weapon=nil, mult=0.5 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	callbackOnMeleeAttack = function(self, eff, target, hitted, crit, weapon, damtype, mult, dam)
		if weapon == self.combat then return end --not with unarmed
		if eff.expired then return end
		eff.expired = true
		eff.dur = 0
		--self.removeEffect(self.EFF_REK_HEKA_MAGPIE_WEAPONS)
		self:attackTargetWith(target, eff.weapon, nil, eff.mult)
	end,
}

newEffect{
	name = "REK_HEKA_IMMERSED", image = "talents/rek_heka_titanic_immersion.png",
	desc = _t"Immersed",
	long_desc = function(self, eff) return ("Projected into the warped realm of a hekatonkheire, reducing damge taken by %d%%, reducing damage dealt by %d%%, and being continually beaten for %d%% damage."):tformat(eff.resist, eff.numb, eff.dam*100) end,
	type = "magical",
	subtype = { warp=true },
	status = "detrimental",
	parameters = { power=0.5, stacks=1, max_stacks=3 },
	on_gain = function(self, err) return _t"#Target# is drawn towards the other place!", _t"+Immersed" end,
	on_lose = function(self, err) return _t"#Target# returns to normal space.", _t"-Immersed" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("numbed", eff.numb)
		if core.shader.active() then
			self:effectParticles(eff, {type="shader_shield", args={toback=true,  size_factor=1, img="heka_immersed"}, shader={type="rotatingshield", noup=2.0, cylinderRotationSpeed=1.7, appearTime=0.2}})
			self:effectParticles(eff, {type="shader_shield", args={toback=false, size_factor=1, img="heka_immersed"}, shader={type="rotatingshield", noup=1.0, cylinderRotationSpeed=1.7, appearTime=0.2}})
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("numbed", eff.tmpid)
	end,
	callbackOnHit = function(self, eff, cb, src)
		cb.value = cb.value - (cb.value * (1 - eff.resist/100))
		return cb.value
	end,
	on_timeout = function(self, eff)
		self:removeTemporaryValue("numbed", eff.tmpid)

		if eff.src and not eff.src.dead then
			eff.src:attackTarget(self, nil, eff.dam, true, true)
		end

		eff.tmpid = self:addTemporaryValue("numbed", eff.numb)
	end,
}

newEffect{
	name = "REK_HEKA_SUDDEN_INSIGHT", image = "talents/rek_heka_otherness_sudden_insight.png",
	desc = _t"Sudden Insight",
	long_desc = function(self, eff) return ("Increased critical chance by %d and power by %d%%"):tformat(eff.chance, eff.power) end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { power = 5, chance=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physcrit", eff.chance)
		self:effectTemporaryValue(eff, "combat_spellcrit", eff.chance)
		self:effectTemporaryValue(eff, "combat_critical_power", eff.power)
		eff.particle = self:addParticles(Particles.new("circle", 1, {base_rot=1, oversize=0.5, a=150, appear=8, y=-0.68, speed=0, img="sudden_insight_eye", radius=0}))
	end,
	deactivate = function(self, eff) self:removeParticles(eff.particle) end,
}

newEffect{
	name = "REK_HEKA_INVESTED", image = "talents/rek_heka_otherness_sudden_insight.png",
	desc = _t"Invested Hands",
	long_desc = function(self, eff)
		local total = 0
		for i, instance in pairs(eff.investitures) do
			total = total + instance.power
		end
		return ("%d of your hands are busy elsewhere"):tformat(total)
	end,
	type = "other",
	subtype = { hands=true },
	status = "neutral",
	no_remove = true,
	decrease = 0,
	charges = function(self, eff)
		local total = 0
		for i, instance in pairs(eff.investitures) do
			total = total + instance.power
		end
		return math.round(total)
	end,
	--parameters = { cost = 0 },
	on_merge = function(self, old_eff, new_eff)
		-- mark old damage instances to expire
		for i, instance in pairs(old_eff.investitures) do
			old_eff.investitures[i].dur_m = instance.dur_m + new_eff.dur - old_eff.dur
		end
		-- add new instance
		new_eff.investitures[1].dur_m = new_eff.dur
		old_eff.investitures[#old_eff.investitures+1] = new_eff.investitures[1]

		if old_eff.costid then self:removeTemporaryValue("max_hands", old_eff.costid) end
		local total = 0
		for i, instance in pairs(old_eff.investitures) do
			total = total + instance.power
		end
		old_eff.costid = self:addTemporaryValue("max_hands", -total)
		self:incHands(0)
		--if self:getHands() > self:getMaxHands() then self.hands = self:getMaxHands() end
		return old_eff
	end,
	activate = function(self, eff)
		eff.investitures[1].dur_m = eff.dur
	end,
	deactivate = function(self, eff)
		if eff.costid then self:removeTemporaryValue("max_hands", eff.costid) end
	end,
	on_timeout = function(self, eff)
		local total = 0
		for i, instance in pairs(eff.investitures) do
			-- applications that have lived out their allotted time are cleared.
			eff.investitures[i].dur_m = instance.dur_m - 1
			if instance.dur_m == 0 then
				if self:knowTalent(self.T_REK_HEKA_HELPING_HEALING) then
					self:callTalent(self.T_REK_HEKA_HELPING_HEALING, "doHeal", instance.power)
				end
				eff.investitures[i].power = 0
				eff.investitures[i] = nil
			elseif instance.dur_m < 0 then
				eff.investitures[i].power = 0
				eff.investitures[i] = nil
			elseif eff.investitures[i].power > 0 then
				total = total + eff.investitures[i].power
			end
		end

		-- Update
		if eff.costid then self:removeTemporaryValue("max_hands", eff.costid) end
		local total = 0
		for i, instance in pairs(eff.investitures) do
			total = total + instance.power
		end
		eff.costid = self:addTemporaryValue("max_hands", -total)
		self:incHands(0)

		if total <= 1 then
			self:removeEffect(self.EFF_REK_HEKA_INVESTED, true, true)
		end
	end,
}

newEffect{
	name = "REK_HEKA_PULLED", image = "talents/rek_heka_harming_inexorable_pull.png",
	desc = _t"Inexorable Pull",
	long_desc = function(self, eff) return ("Pinned by disembodied hands, sliding towards the hekatonkheire"):tformat() end,
	type = "other",
	subtype = { grapple=true },
	status = "detrimental",
	parameters = { power = 1 },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		if not self:attr("never_move") then self:removeEffect(self.EFF_REK_HEKA_PULLED) end
		-- Manually test knockback immunity because we're ignoring the pin
		if rng.percent(100 - (self:attr("knockback_immune") or 0)) then
			self:pull(eff.src.x, eff.src.y, 1)
		end
	end,
}

newEffect{
	name = "REK_HEKA_GRASPED", image = "talents/rek_heka_harming_titans_grasp.png",
	desc = _t"Titan's Grasp",
	long_desc = function(self, eff) return ("Pinned by disembodied hands, taking %d damage per turn.  Can break free by dealing %d damage to other targets."):tformat(eff.power, eff.health*10) end,
	type = "physical",
	subtype = { grapple=true, pin=true, silence=true },
	status = "detrimental",
	parameters = { power = 5, health=10, silence=0 },
	activate = function(self, eff)
		if self:canBe("pin") then
			self:effectTemporaryValue(eff, "never_move", 1)
			
			if not self.add_displays then
				self.add_displays = { Entity.new{image='npc/bone_grab_pin.png', display=' ', display_on_seen=true } }
				eff.added_display = true
			end
			self:removeAllMOs()
			game.level.map:updateMap(self.x, self.y)
			
		end
		if (eff.silence > 0) and self:canBe("silence") then
			self:effectTemporaryValue(eff, "silence", 1)
		end
	end,
	deactivate = function(self, eff)
		if eff.added_display then
			self.add_displays = nil
			self:removeAllMOs()
			game.level.map:updateMap(self.x, self.y)
		end
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.PHYSICAL).projector(eff.src, self.x, self.y, DamageType.PHYSICAL, eff.power)
		if not self:checkHit(eff.savepower, self:combatPhysicalResist(), 0, 95, 5) then eff.dur = math.max(0, eff.dur - 1) end
	end,
}
class:bindHook("DamageProjector:final", function(self, hd)
	local src = hd.src
	local dam = hd.dam

	if src.hasEffect then
		local eff = src:hasEffect(src.EFF_REK_HEKA_GRASPED)
		if eff then
			local absorbed = dam * 0.1
			game:delayedLogDamage(src, hd.target, 0, ("#c68642#(%d to grasping hands)#LAST#"):tformat(absorbed), false)
			--eff.health = eff.health - absorbed
			hd.dam = dam - absorbed
		end
	end
	return hd
end)


newEffect{
	name = "REK_HEKA_CHOKE_READY", image = "talents/rek_heka_harming_chokehold.png",
	desc = _t"Chokehold Prepared",
	long_desc = function(self, eff) return ("Next use of Titan's Grasp will also silence the target"):tformat() end,
	type = "physical",
	subtype = { hands=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physcrit", eff.chance)
		self:effectTemporaryValue(eff, "combat_spellcrit", eff.chance)
		self:effectTemporaryValue(eff, "combat_critical_power", eff.power)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "REK_HEKA_FORFEND", image = "talents/rek_heka_helping_forfend.png",
	desc = _t"Forfend",
	long_desc = function(self, eff)
		return ("Blocking up to %d total damage."):
			tformat(self.heka_block or 0)
	end,
	type = "physical",
	subtype = {tactic=true},
	status = "beneficial",
	parameters = {block = 0},
	activate = function(self, eff)
		self.heka_block = eff.block
		if core.shader.active() then
			self:effectParticles(eff, {type="shader_shield", args={toback=false, size_factor=2, img="open_palm_block_tentacles2"}, shader={type="tentacles", backgroundLayersCount=-4, appearTime=0.3, time_factor=500, noup=0.0}})
		end
	end,
	deactivate = function(self, eff)
		self.heka_block = nil
	end,
	callbackOnTakeDamage = function(self, eff, src, x, y, type, value, tmp)
		if not (self:attr("heka_block") ) or value <= 0 then return end

		local dam = value
		game:delayedLogDamage(src, self, 0, ("#STEEL_BLUE#(%d blocked)#LAST#"):tformat(math.min(dam, self.heka_block)), false)
		if dam < self.heka_block then
			self.heka_block = self.heka_block - dam
			dam = 0
			
			-- counterstrike
			if not eff.did_counterstrike and src.life then
			full = true
			if not self.__counterstrike_recurse then
				self.__counterstrike_recurse = true
				if not self:knowTalent(self.T_ETERNAL_GUARD) then eff.did_counterstrike = true end
				src:setEffect(src.EFF_COUNTERSTRIKE, 2, {power=eff.block, no_ct_effect=true, src=self, crit_inc=crit_inc, nb=nb})
				self.__counterstrike_recurse = nil
			end
		end
		eff.did_block = true
		self:fireTalentCheck("callbackOnBlock", eff, dam, type, src, blocked)
		else
			dam = dam - self.heka_block
			self.heka_block = 0
		end

		-- If we are at the end of the capacity
		if self.heka_block <= 0 then
			game.logPlayer(self, "#ORCHID#Your hands cannot block any more attacks!#LAST#")
			self:removeEffect(self.EFF_REK_HEKA_FORFEND)
		end

		return {dam = dam}
	end,
}

newEffect{
	name = "REK_HEKA_OVERWATCH", image = "talents/rek_heka_eyesight_overwatch.png",
	desc = _t"Oversight",
	long_desc = function(self, eff) return ("This creature feels safer with its eyes around."):tformat() end,
	type = "mental",
	subtype = { warp=true },
	status = "beneficial",
	parameters = { power=0.5 },
	activate = function(self, eff)
		eff.regenid = self:addTemporaryValue("life_regen", eff.power)
		eff.pid = self:addTemporaryValue("combat_physresist", 8*eff.power)
		eff.mid = self:addTemporaryValue("combat_mentalresist", 8*eff.power)
		eff.sid = self:addTemporaryValue("combat_spellresist", 8*eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_spellresist", eff.sid)
		self:removeTemporaryValue("combat_mentalresist", eff.mid)
		self:removeTemporaryValue("combat_physresist", eff.pid)
		self:removeTemporaryValue("life_regen", eff.regenid)
	end,
}

newEffect{
	name = "REK_HEKA_ICHOR", image = "talents/rek_heka_splinter_teeth.png",
	desc = _t"Flow",
	long_desc = function(self, eff) return ("This creature has become a swarm of disembodied extremities."):tformat() end,
	charges = function(self, eff) return eff.stacks end,
	type = "magical",
	subtype = { might=true },
	status = "beneficial",
	parameters = { power=0.5, stacks=1, max_stacks=3 },
	on_merge = function(self, old_eff, new_eff, e)
		self:removeTemporaryValue("combat_dam", old_eff.powid)
		if old_eff.regenid then self:removeTemporaryValue("life_regen", old_eff.regenid) end
		if old_eff.defid then self:removeTemporaryValue("combat_def", old_eff.defid) end
		if old_eff.accid then self:removeTemporaryValue("combat_atk", old_eff.accid) end
		if new_eff.stacks > old_eff.stacks then
			old_eff.stacks = new_eff.stacks
			old_eff.dur = new_eff.dur
		end
		local pow = old_eff.stacks^0.5
		old_eff.powid = self:addTemporaryValue("combat_dam", 5*pow)
		if self:knowTalent(self.T_REK_HEKA_SPLINTER_ORGANS) then
			old_eff.regenid = self:addTemporaryValue("life_regen", 2.5*pow)
		end
		if self:knowTalent(self.T_REK_HEKA_SPLINTER_ARMS) then
			old_eff.defid = self:addTemporaryValue("combat_def", 5*pow)
		end
		if self:knowTalent(self.T_REK_HEKA_SPLINTER_ATTACK) then
			old_eff.accid = self:addTemporaryValue("combat_atk", 5*pow)
		end
		return old_eff
	end,
	activate = function(self, eff)
		local pow = eff.stacks^0.5
		eff.powid = self:addTemporaryValue("combat_dam", 5*pow)
		if self:knowTalent(self.T_REK_HEKA_SPLINTER_ORGANS) then
			eff.regenid = self:addTemporaryValue("life_regen", 2.5*pow)
		end
		if self:knowTalent(self.T_REK_HEKA_SPLINTER_ARMS) then
			eff.defid = self:addTemporaryValue("combat_def", 5*pow)
		end
		if self:knowTalent(self.T_REK_HEKA_SPLINTER_ATTACK) then
			eff.accid = self:addTemporaryValue("combat_atk", 5*pow)
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.powid)
		if eff.regenid then self:removeTemporaryValue("life_regen", eff.regenid) end
		if eff.defid then self:removeTemporaryValue("combat_def", eff.defid) end
		if eff.accid then self:removeTemporaryValue("combat_atk", eff.accid) end
	end,
}

newEffect{
	name = "REK_HEKA_PANOPTICON", image = "talents/rek_heka_eyesight_panopticon.png",
	desc = _t"Panopticon",
	long_desc = function(self, eff) return (_t"The target sees no way out, rendering it inactive.") end,
	type = "other",
	subtype = { paralysis=true },
	status = "detrimental",
	parameters = { power=1 },
	on_lose = function(self, err) return _t"#Target# regains the will to fight.", _t"-Unable to act" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "dont_act", 1)
		eff.particle = self:addParticles(Particles.new("circle", 1, {oversize=1, a=220, shader=true, appear=12, img="oculatus", speed=0, base_rot=180, radius=0}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "REK_HEKA_DRUMMING", image = "talents/rek_heka_mountain_earthdrum.png",
	desc = _t"Earthdrum",
	long_desc = function(self, eff) return ("The target is moving and shifting the ground around them"):tformat() end,
	type = "magical",
	subtype = { warp=true },
	status = "beneficial",
	parameters = {turns = 0},
	deactivate = function(self, eff)
		local cd_base = self:getTalentCooldown(self.T_REK_HEKA_MOUNTAIN_EARTHDRUM) or 8
		local nb = self:callTalent(self.T_REK_HEKA_MOUNTAIN_EARTHDRUM, "getNb") or eff.turns
		local cd = math.ceil(cd_base * eff.turns / nb)
		self:startTalentCooldown(self.T_REK_HEKA_MOUNTAIN_EARTHDRUM, cd)
	end,
}

newEffect{
	name = "REK_HEKA_LASHING_POWER", image = "talents/rek_heka_veiled_lashing.png",
	desc = "Thoroughly Lashing",
	long_desc = function(self, eff) return ("Better critical hits"):format() end,
	type = "physical",
	subtype = { hands=true, arcane = true },
	status = "beneficial",
	parameters = { chance = 5, power = 10},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_spellcrit", eff.chance)
		self:effectTemporaryValue(eff, "combat_critical_power", eff.power)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "REK_HEKA_EYELIGHT", image = "talents/rek_heka_veiled_highlight.png",
	desc = _t"Eyelighted",
	long_desc = function(self, eff) return ("The target is weakened, all damage it does is reduced by %d%%."):tformat(eff.reduce) end,
	type = "magical",
	subtype = { hands=true,},
	status = "detrimental",
	parameters = {power=10},
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("numbed", eff.power)
		eff.particle = self:addParticles(Particles.new("spinning_halo", 1, {img="eyes_small"}))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("numbed", eff.tmpid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "REK_HEKA_EYE_STOCK", image = "talents/rek_heka_watcher_respawn.png",
	desc = _t"Eye Stock",
	long_desc = function(self, eff) return ("This creature's eyes are pressing into this reality, ready to appear %d turns sooner."):tformat(eff.stacks) end,
	charges = function(self, eff) return eff.stacks end,
	type = "magical",
	subtype = { hands=true },
	status = "beneficial",
	parameters = { stacks=1, max_stacks=3 },
	on_merge = function(self, old_eff, new_eff, e)
		new_eff.stacks = util.bound(old_eff.stacks + new_eff.stacks, 1, new_eff.max_stacks)
		return new_eff
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "REK_HEKA_EYELEMENT_EYE", image = "talents/rek_heka_watcher_element.png",
	desc = _t"Eyelemental",
	long_desc = function(self, eff)
		return ("Increases resistance to %s by +%d%%"):tformat(eff.element, eff.resist)
	end,
	type = "other",
	subtype = { eyes=true },
	status = "beneficial",
	decrease = 0,
	parameters = { element=DamageType.ARCANE, resist=10 },
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("resists", {[eff.element] = eff.resist})
		if self.summoner then
			eff.summonerid = self.summoner:addTemporaryValue("resists", {[eff.element] = eff.resist/2})
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.tmpid)
		if eff.summonerid and self.summoner then
			self.summoner:removeTemporaryValue("resists", eff.summonerid)
		end
	end,
}

newEffect{
	name = "REK_HEKA_ARENA", image = "talents/rek_heka_sybarite_revel.png",
	desc = _t"Lord of the Arena",
	long_desc = function(self, eff) return ("The target's damage has been increased by %d%% and its resistances by %d%%."):tformat(eff.damage, eff.resist) end,
	type = "magical",
	subtype = { arcane=true },
	status = "beneficial",
	parameters = { damage=10, resist=10, damageMax=10, resistMax=10, walls=1 },
	activate = function(self, eff)
		local proportion = math.max(1, math.log(eff.walls)) / math.log(180) -- don't require them to be in the center of a huge circle of walls to best use it
		eff.damage = eff.damageMax * proportion
		eff.resist = eff.resistMax * proportion
		self:effectTemporaryValue(eff, "size_category", 1)
		self:effectTemporaryValue(eff, "resists", {all = eff.resist})
		self:effectTemporaryValue(eff, "inc_damage", {all = eff.damage})
	end,
	deactivate = function(self, eff)
	end,
}

load("/data-classhekatonkheire/effects_kharybdian.lua")
