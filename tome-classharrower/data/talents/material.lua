newTalent{
	name = "Glass Wings", short_name = "REK_GLR_MATERIAL_WINGS",
	type = {"psionic/mindshaped-material", 1},
	require = wil_req1,
	points = 5,
	range = function(self, t) return math.min(14, math.floor(self:combatTalentScale(t, 6, 10))) end,
	cooldown = 18,
	psi = 8,
	target = function(self, t) return {type="widebeam", radius=1, nolock=true, range=self:getTalentRange(t), selffire=false, talent=t} end,
	getDamage = function(self, t) return self:combatTalentMindDamage(t, 20, 250) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local tx, ty, target = self:getTargetLimited(tg)
		if not tx or not ty then return nil end
		if not self:canProject(tg, tx, ty) then return nil end
		if game.level.map(tx, ty, engine.Map.ACTOR) then return nil end
		if game.level.map:checkEntity(tx, ty, Map.TERRAIN, "block_move") then return nil end


		local hit = false
		local dam = self:mindCrit(t.getDamage(self, t))
		self:project(tg, tx, ty, function(px, py)
									 DamageType:get(DamageType.PHYSICALBLEED).projector(self, px, py, DamageType.PHYSICALBLEED, dam)
			local target = game.level.map(px, py, Map.ACTOR)
			if target then hit = true end
		end)

		--local ox, oy = self.x, self.y
		self:move(tx, ty, true)
		if hit then
			game:onTickEnd(function() self:alterTalentCoolingdown(t.id, -math.floor((self.talents_cd[t.id] or 0) * 0.67)) end)
		end
				
		return true
	end,
	info = function(self, t)
		return ([[Ultra-thin plates of crystal allow you to fly short distances on telekinetic currents.  Jump to a space within range %d, cutting creatures in your path with the crystal edges for %0.2f physical bleed damage.  If you hit anything, this talent's cooldown is reduced by 2/3.
Mindpower: improves	damage]]):
		format(self:getTalentRange(t), damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t)*1.5))
	end,
}

newTalent{
	name = "Silken Armor", short_name = "REK_GLR_MATERIAL_ARMOR",
	type = {"psionic/mindshaped-material", 2},
	require = wil_req2,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	tactical = { BUFF = 2 },
	getCost = function(self, t) return 3 end,
	getReduction = function(self, t) return self:combatTalentMindDamage(t, 10, 50) + self.level end,
	callbackOnHit = function(self, t, cb, src, death_note)
		if not self:hasLightArmor() then
			--game.logPlayer(self, ("DEBUG - Not in light armor"):format(sx, sy))
			return end
		if self:getPsi() < (self:getMaxPsi() / 2) then
			--game.logPlayer(self, ("DEBUG - Not enough psi!"):format(sx, sy))
			return end
		local dam = cb.value
		local cost = t.getCost(self, t)
		if dam < t.getReduction(self, t) then cost = cost * dam / t.getReduction(self, t) end
		if self:getPsi() < cost then return end -- in case max psi is really tiny?
		
		if dam > 0 and not self:attr("invulnerable") then					
			local reduce = math.min(t.getReduction(self, t), dam)
			dam = dam - reduce
			local d_color = "#4080ff#"
			game:delayedLogDamage(src, self, 0, ("%s(%d to silken armor)"):format(d_color, reduce, stam_txt, d_color), false)
			cb.value = dam
			self:incPsi(-1 * cost)
		end
		return cb
	end,
	activate = function(self, t)
		--TODO particle
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Rearrange the fibers of your armor into a psionically conductive matrix that protect you from harm. Incoming damage will be reduced by %d, costing up to #4080ff#%d psi#LAST# per hit.
This only takes effect while wearing light or cloth armor and while your psi pool over 50%% full.
Mindpower: increases damage reduction
Character Level: increases damage reduction
]]):format(t.getReduction(self, t), t.getCost(self, t))
	end,
}

newTalent{
	name = "Thread Wall", short_name = "REK_GLR_MATERIAL_WALL",
	type = {"psionic/mindshaped-material", 3},
	require = wil_req3,
	points = 5,
	cooldown = 20,
	psi = 18,
	range = 6,
	requires_target = true,
	no_npc_use = true,
	tactical = { ATTACKAREA = { MIND = 1.5 } },
	target = function(self, t) return {type="hit", friendlyblock = false, nolock=true, range=self:getTalentRange(t)} end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	getStats = function(self, t) return self:getWil()*0.5 end,
	getLifeRating = function(self, t) return math.floor(self:combatStatScale("wil", 0.5, 2)) end,
	makeWall = function(self, t, x, y)
		local oe = game.level.map(x, y, Map.TERRAIN)
		if not oe or oe.special then return end
		if game.level.map:checkAllEntities(x, y, "block_move") then return end
		local NPC = require "mod.class.NPC"
		local wall = NPC.new{
			type = "immovable", subtype = "wall",
			display = "#", blood_color = colors.GRAY,
			stats = { str=t.getStats(self, t), dex=t.getStats(self, t), wil=t.getStats(self, t), mag=t.getStats(self, t), con=t.getStats(self, t), cun=t.getStats(self, t) },
			infravision = 10,
			no_breath = 1,
			never_move = 1,
			cant_be_moved = 1,
			name = "thread wall", color=colors.GRAY,
			desc = "A wall of countless thin fibers blocks your path.",
			resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/iceblock.png", display_h=1, display_y=-1}}},
			level_range = {self.level, self.level}, exp_worth = 0,
			rank = 2,
			size_category = 4,
			block_sight = true,
			autolevel = "wildcaster",
			life_rating = 10 + t.getLifeRating(self, t),
			negative_status_effect_immune = 1,
			combat_armor = math.floor(self.level^.75),
			combat_armor_hardiness = 100,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDuration(self, t),
			on_act = function(self)
				self:useEnergy()
			end,
			
			ai = "summoned", ai_real = "tactical", ai_state = { ai_move="move_simple", talent_in=1, ally_compassion=0 },
			no_drops = true, keep_inven_on_death = false,
			faction = self.faction,
												}
		wall:resolve()
		wall:resolve(nil, true)		
		game.zone:addEntity(game.level, wall, "actor", x, y)
		if target then m:setTarget(target) end
		if game.party:hasMember(self) then
			wall.remove_from_party_on_death = true
			game.party:addMember(wall, {control=false, temporary_level=true, type="summon", title="Summon"})
		end
	end,
	action = function(self, t)
		game.logPlayer(self, "Target the start of the wall...")
		local tg = self:getTalentTarget(t)
		local sx, sy, target = self:getTarget(tg)
		if not self:canProject(tg, sx, sy) then return end

		game.logPlayer(self, "Target the end of the wall...")

		tgEnd = {type="beam", start_x=sx, start_y=sy, nolock=true, range=self:getTalentRange(t), no_start_scan=true}
		--game.target.target.x,game.target.target.y = defaultX,defaultY
		--game.target.target.entity = nil
		dx, dy = self:getTarget(tgEnd)
		if not dx then
			game.logPlayer(self, "Invalid end point")
			return
		end
		if not self:canProject(tgEnd, dx, dy) then
			game.logPlayer(self, "Can't reach endpoint")
			return
		end
		if not self:hasLOS(dx, dy) then
			game.logPlayer(self, "Need line of sight to the end of the wall")
			return
		end

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
		return true
	end,
	info = function(self, t)
		return ([[Weave together tiny scraps into a resilient barrier, materializing a line of destructible but durable wall segments.  Each wall segment blocks line of sight and lasts for %d turns.
Willpower: improves the health of each wall segment]]):format(t.getDuration(self, t))
	end,
}


newTalent{
	name = "Cocoon", short_name = "REK_GLR_MATERIAL_COCOON",
	type = {"psionic/mindshaped-material", 4},
	require = wil_req4,
	points = 5,
	cooldown = 12,
	psi = 12,
	getVulnerability = function(self, t) return math.floor(self:combatTalentMindDamage(t, 10, 40)) end,
	getDuration = function(self, t) return self:combatTalentLimit(t, 8, 3, 5) end,
	range = 10,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end		
		target:setEffect(target.EFF_REK_GLR_COCOONED, t.getDuration(self, t), {power=t.getVulnerability(self, t), src=self})
		return true
	end,
	info = function(self, t)
		return ([[Reshape the terrain around a target into a snare, pinning them (#SLATE#no save, ignores immunity#LAST#) for %d turns.  The snare prevents them from properly defending themselves, reducing their resistance to damage by %d%%.]]):format(t.getDuration(self, t), t.getVulnerability(self, t))
	end,
}