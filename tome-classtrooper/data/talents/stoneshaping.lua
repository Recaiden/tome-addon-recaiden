newTalent{
	name = "Stone Rain", short_name = "REK_OCLT_STONESHAPING_RAIN",
	type = {"occultech/stoneshaping", 1}, require = cun_req1, points = 5,
	mode = "passive",
	getScaling = function(self, t) return self:combatTalentScale(t, 0.8, 1.8) end,
	getDuration = function(self, t) return 4 end,
	callbackOnTalentPost = function(self, t, ab)
		if not ab.type[1]:find("^race/") and not ab.type[1]:find("^undead/") not ab.type[1]:find("^construct/") then
			return
		end
		local durscale = 1
		if ab.type[2] == 1 then durscale = 2 end
		self:setEffect(self.EFF_REK_OCLT_STONE_RAIN, durscale * t:_getDuration(self), {src=self, power=t:_getScaling(self)})
	end,
	info = function(self, t)
		local flavor = self.descriptor.race == "Dwarf" and _t"You enhance your natural toughness with a layer of reactive lithomachinery for self-defense." or _t"Tiny mechanisms gather a web of rock around you, lashign out when you exert yourself."
		return ([[%s

When you activate a racial talent, stone rain begins lashing out at enemies for %d turns, dealing damage equal to %d%% of your armor the first time each turn that you damage anyone.  The duration is doubled if it's a Tier 1 talent.]]):tformat(flavor, t:_getDuration(self1), 100 *t.getScaling(self, t))
	end,
}

newTalent{
	name = "Stone Barrier", short_name = "REK_OCLT_STONESHAPING_BARRIER",
	type = {"occultech/stoneshaping", 2},	require = cun_req2, points = 5,
	coldown = 5,
	requires_target = true,
	range = 0,
	tactical = { DEFEND = 1 },

	mode = "sustained",
	no_sustain_autoreset = true,
	iconOverlay = function(self, t, r)
		local val = r.value or 0
		if val <= 0 then return "" end
		local fnt = "buff_font_small"
		if val >= 1000 then fnt = "buff_font_smaller" end
		return tostring(math.ceil(val)), fnt
	end,
	deactivate_on = {no_combat=true, run=true, rest=true},
	
	target = function(self, t)
		return {type="cone", range=0, selffire=false, radius=1, talent=t}
	end,
	getShield = function(self, t) return self:getShieldAmount(self:combatTalentPhysicalDamage(t, 20, 480)) end,
	getDuration = function(self, t) return 5+math.floor(self:combatTalentScale(t, 1, 4)) end,
	callbackOnHit = function(self, t, cb, src, dt)
		if not src.x or not src.y then return nil end

		local r = self:isTalentActive(t.id)
		if not r then return end
		if not cb.value then return end

		local dir = utils.dir(self.x, self.y, src.x, src.y)
		if not r.dirs[dir] then return end

		local blocked = max.min(r.value, cb.value)

		cb.value = cb.value - blocked
		r.value = r.value - blocked
		
		if blocked > 0 then
			game:delayedLogDamage(src, self, 0, ("%s(%d to stone barrier)#LAST#"):tformat(DamageType:get(type).text_color or "#aaaaaa#", blocked), false)
		end
	end,	
	activate = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local ret = {
			dirs = {}
			value = t:_getShield(self) * (1.5 + (self.combat_critical_power or 0) / 100),
			__update_display = true,
		}
		
		self:project(tg, x, y, function(px, py)
									 ret.dirs[util.getDir(self.x, self.y, px, py)] = true
		end)
		game:playSoundNear(self, "talents/spell_generic2")

		return ret
	end,
	deactivate = function(self, t, r)
		if r.particles then self:removeParticles(r.particles) end
		r.particles = nil
		return true
	end,
	info = function(self, t)
		local flavor = self.descriptor.race == "Dwarf" and _t"Assemble your lithomachinery into a frontal shield, covering a small cone." or _t"Stone leaps up to defend you, forming a barrier in a small cone."
		return ([[%s

Any damage that comes from the same direction as the shield will be blocked, up to %d%% points.  This talent dractivates when the shield is expended, or when you rest or run.  The amount blocked scales with physical power and critical damage, but cannot trigger critical effects.]]):tformat(flavor, self:getShield(t))
	end,
}

newTalent{
	name = "Stone Seal", short_name = "REK_OCLT_STONESHAPING_SEAL",
	type = {"occultech/stoneshaping", 3}, require = cun_req3, points = 5,
	cooldown = 15,
	tactical = { DISABLE = { stun = 1.5, instakill = 1.5 } },
	range = function(self, t) return math.floor(self:combatTalentScale(t, 3, 7)) end,
	requires_target = true,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(tx, ty)
									 local target = game.level.map(tx, ty, Map.ACTOR)
									 if not target then return end
									 
									 if target:canBe("stun") and target:canBe("stone") and target:canBe("instakill") then
										 target:setEffect(target.EFF_STONED, t.getDuration(self, t), {apply_power=self:combatSpellpower()})
										 game.level.map:particleEmitter(tx, ty, 1, "archery")
									 end
		end)
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local flavor = self.descriptor.race == "Dwarf" and _t"Direct your lithomachines to overun a target" or _t"Turn a target into stone"
		return ([[%s, petrifying them for %d turns.

Pertified creatures are unable to act or regen life, and if hit for at least 30%% of its life, will shatter die.While petrified, creatures are highly resistant to fire and lightning, and somewhat resistant to physical damage.  Checks stun, petrification, and instant death immunity.]]):tformat(flavor, t.getDuration(self, t))
	end,
}

newTalent{
	name = "Stone Corridor", short_name = "REK_OCLT_STONESHAPING_CORRIDOR",
	type = {"occultech/stoneshaping", 4}, require = cun_req4, points = 5,
	cooldown = 20,
		range = 6,
	requires_target = true,
	no_npc_use = true,
	tactical = { ATTACKAREA = { MIND = 1.5 } },
	target = function(self, t) return {type="hit", friendlyblock = false, nolock=true, range=self:getTalentRange(t)} end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	makeWall = function(self, t, x, y)
		local oe = game.level.map(x, y, Map.TERRAIN)
		if not oe or oe.special or oe:attr("temporary")  then return end
		if game.level.map:checkAllEntities(x, y, "block_move") then return end
		local NPC = require "mod.class.NPC"

		local e = Object.new{
			old_feat = oe,
			name = _t"stone wall",
			image = oe.image,
			add_mos = table.clone(oe.add_mos or {}, true),
			add_displays = table.clone(oe.add_displays or {}),
			display = '#', color_r=255, color_g=255, color_b=255, back_color=colors.GREY,
			desc = _t"a summoned wall of stone",
			type = "wall", --subtype = "floor",
			always_remember = true,
			can_pass = {pass_wall=1},
			does_block_move = true,
			show_tooltip = true,
			block_move = true,
			block_sight = true,
			temporary = t.getDuration(self, t),
			x = x, y = y,
			canAct = false,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				if self.temporary <= 0 then
					game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
					game.nicer_tiles:updateAround(game.level, self.x, self.y)
					game.level:removeEntity(self)
					game.level.map:scheduleRedisplay()
				end
			end,
			dig = function(src, x, y, old)
				game.level:removeEntity(old)
				game.level.map:scheduleRedisplay()
				return nil, old.old_feat
			end,
			summoner_gain_exp = true,
			summoner = self,
		}
		e.add_displays[#e.add_displays+1] = Grid.new{image="terrain/spell_stonewall_0"..rng.range(1,3)..".png", z=19}
		e.tooltip = mod.class.Grid.tooltip
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN, e)
	end,
	action = function(self, t)
		game.logPlayer(self, "Target the start of the wall...")
		local tg = self:getTalentTarget(t)
		local sx, sy, target = self:getTarget(tg)
		if not self:canProject(tg, sx, sy) then return end

		game.logPlayer(self, "Target the end of the wall...")

		tgEnd = {type="beam", start_x=sx, start_y=sy, nolock=true, range=self:getTalentRange(t), no_start_scan=true}
		dx, dy = self:getTarget(tgEnd)
		if not dx then
			game.logPlayer(self, "Invalid end point")
			return
		end
		
		local wall = false
		local tgWall = {type="ball", range=self:getTalentRange(t), radius=1, talent=t}
		local grids = self:project(
			tgWall, dx, dy,
			function(tx, ty)
				if game.level.map:checkEntity(tx, ty, Map.TERRAIN, "block_move", self) then wall = true end
			end
		)
		grids = self:project(
			tgWall, sx, sy,
			function(tx, ty)
				if game.level.map:checkEntity(tx, ty, Map.TERRAIN, "block_move", self) then wall = true end
			end
		)
		if not wall then return end
		
		self:project(
			tgEnd, dx, dy,
			function(px, py, tgEnd, self)
				t.makeWall(self, t, px, py)
      end)
		t.makeWall(self, t, sx, sy)
		self:resetCanSeeCache()
		if self == game.player then
			for uid, e in pairs(game.level.entities) do
				if e.x then
					game.level.map:updateMap(e.x, e.y)
				end
			end game.level.map.changed = true
		end
		game:playSoundNear(self, "talents/cloth")
		return true
	end,
	info = function(self, t)
		return ([[Erect a wall of stone between two locations, one of which must be adjacent to a permanent wall.  It will crumble away after %d turns.]]):tformat(t.getDuration(self, t))
	end,
}
