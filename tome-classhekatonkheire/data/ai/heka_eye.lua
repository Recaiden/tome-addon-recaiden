local Astar = require "engine.Astar"
local DamageType = require "engine.DamageType"

-- Eye Action Priority
-- Teleport back within range of summoner
-- Get bored after 10 turns fighting the same enemy
-- Confront an enemy if you have one
-- Move towards a location if you have one
-- 65% Chance to pick a new enemy within range 8 and confront them
-- Pick a new location withing range 4 and move towards it.

-- Confronting-an-enemy
-- Chance to bite an enemy to heal self, 10% @ 75% life, guaranteed at 30% life or les
-- 15% chance to bite even if not hurt
-- variable chance to Stagger
-- If within range 6, chance to use Lash
-- If outside range 3, another chance to use Lash
-- (20% chance to get bored)
-- If within 5, retreat but keep line of sight
-- Move closer

local function clearTarget(self)
	self.ai_target.actor, self.ai_target.x, self.ai_target.y, self.ai_target.blindside_chance, self.ai_target.attack_spell_chance, self.turns_on_target, self.focus_on_target = nil, nil, nil, nil, nil, 0, false
end

local function eyeChooseActorTarget(self)

	-- taken from "target_simple" but selects a target the summoner can see within the eye's max range from the summoner
	local arr = self.summoner.fov.actors_dist
	local act
	local sqsense = self.ai_state.actor_range
	sqsense = sqsense * sqsense
	local actors = {}
	for i = 1, #arr do
		act = self.summoner.fov.actors_dist[i]
		if act and act ~= self.summoner and self.summoner:reactionToward(act) < 0 and not act.dead and
			(
				-- If it has lite we can always see it
				((act.lite or 0) > 0)
				or
				-- Otherwise check if we can see it with our "senses"
				(self.summoner:canSee(act) and self.summoner.fov.actors[act].sqdist <= sqsense)
			) then

			actors[#actors+1] = act
		end
	end

	if #actors > 0 then
		--game.logPlayer(self.summoner, "#PINK#%s has chosen an actor.", self.name:capitalize())
		self.ai_target.actor = actors[rng.range(1, #actors)]
		self:check("on_acquire_target", act)
		act:check("on_targeted", self)

		return true
	end

	return false
end

local function eyeMoveToActorTarget(self)
	local range = core.fov.distance(self.x, self.y, self.ai_target.actor.x, self.ai_target.actor.y)

	-- chance to heal
	if self.life < self.max_life * 0.75 then
		local chance = (((self.max_life - self.life) / self.max_life * 100) - 20)*2
		if rng.percent(chance) then
					
			-- access talent directly to get its target
			local t = self:getTalentFromId(self.T_REK_HEKA_EYE_BLINDSIDE)
			if self:getTalentRange(t) and self:preUseTalent(t, true, true) then
				if self:useTalent(self.T_REK_HEKA_EYE_BLINDSIDE) then
					self.ai_state.target_time = self.ai_state.target_timeout
					return true
				end
			end
		
			return true
		end
	end
	
	-- use the target blindside chance if it was assigned; otherwise, use the normal chance
	local blindsideChance = self.ai_target.blindside_chance or self.ai_state.blindside_chance
	self.ai_target.blindside_chance = nil
	if rng.percent(blindsideChance) then

		-- access talent directly to get its target
		local t = self:getTalentFromId(self.T_REK_HEKA_EYE_BLINDSIDE)
		if self:getTalentRange(t) and self:preUseTalent(t, true, true) then
			if self:useTalent(self.T_REK_HEKA_EYE_BLINDSIDE) then
				self.ai_state.target_time = self.ai_state.target_timeout
				return true
			end
		end
		
		--game.logPlayer(self.summoner, "#PINK#%s -> blindside", self.name:capitalize())
		return true
	end

	if range <= 1 and self.ai_state.close_attack_spell_chance and rng.percent(self.ai_state.close_attack_spell_chance) then
		-- chance for close spell
		if self:closeAttackSpell() then return true end
	elseif range <= 6 and self.ai_state.far_attack_spell_chance and rng.percent(self.ai_state.far_attack_spell_chance) then
		if self:farAttackSpell() then return true end
	elseif range <= 6 and range >= 4 and self.ai_state.far_attack_spell_chance and rng.percent(self.ai_state.far_attack_spell_chance) then
		if self:farAttackSpell() then return true end
	end


	-- chance to reset target next turn if we are attacking (unless we have been focused)
	if range <= 1 and rng.percent(20) then
		--game.logPlayer(self.summoner, "#PINK#%s is about to attack.", self.name:capitalize())
		if not self.ai_state.focus_on_target then
			self.ai_state.target_time = self.ai_state.target_timeout
		end
	end

	if range <= 5 and self:runAI("flee_dmap_keep_los") then
		self.turns_on_target = (self.turns_on_target or 0) + 1

		--game.logPlayer(self.summoner, "#PINK#%s -> move_complex", self.name:capitalize())
		return true
	end

	if self:runAI("move_complex") then
		self.turns_on_target = (self.turns_on_target or 0) + 1
		
		--game.logPlayer(self.summoner, "#PINK#%s -> move_complex", self.name:capitalize())
		return true
	end

	return false
end

local function eyeChooseLocationTarget(self)
	local locations = {}
	local range = math.floor(self.ai_state.location_range)
	local x, y = self.summoner.x, self.summoner.y

	for i = x - range, x + range do
		for j = y - range, y + range do
			if game.level.map:isBound(i, j)
					and core.fov.distance(x, y, i, j) <= range
					and self:canMove(i, j) then
				locations[#locations+1] = {i,j}
			end
		end
	end

	if #locations > 0 then
		local location = locations[rng.range(1, #locations)]
		self.ai_target.x, self.ai_target.y = location[1], location[2]

		return true
	end

	return false
end

local function eyeMoveToLocationTarget(self)
	if self.x == self.ai_target.x and self.y == self.ai_target.x then
		-- already at target
		return false
	end

	if rng.percent(self.ai_state.phasedoor_chance) then
		local t = self:getTalentFromId(self.T_REK_HEKA_EYE_PHASE_DOOR)
		if self:getTalentRange(t) and self:preUseTalent(t, true, true) then
			if self:useTalent(self.T_REK_HEKA_EYE_PHASE_DOOR) then

				return true
			end
		end
	end

	local tx, ty = self.ai_target.x, self.ai_target.y
	local path = self.eye_path
	if not path or #path == 0 then
		local a = Astar.new(game.level.map, self)
		path = a:calc(self.x, self.y, tx, ty)
	end

	if path then
		self.eye_path = {}
		tx, ty = path[1].x, path[1].y

		-- try to move around actors..if we fail we will just try a a new target
		if not self:canMove(tx, ty, false) then
			local dir = util.getDir(tx, ty, self.x, self.y)
			tx, ty = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).left)
			if not self:canMove(tx, ty, false) then
				tx, ty = util.coordAddDir(self.x, self.y, util.dirSides(dir, self.x, self.y).right)
				if not self:canMove(tx, ty, false) then
					--game.logPlayer(self.summoner, "#PINK#%s move fails", self.name:capitalize())
					return false
				end
			end
		end

		self:move(tx, ty)
		self.turns_on_target = (self.turns_on_target or 0) + 1

		--game.logPlayer(self.summoner, "#PINK#%s -> move", self.name:capitalize())
		return true
	end

	return false
end

newAI("heka_eye", function(self)
	--game.logPlayer(self.summoner, "#PINK#%s BEGINS.", self.name:capitalize())

	-- eyes don't time out, but they can still be set to 0 as a shorthand for getting rid of them
	if self.summon_time <= 0 or self.summoner.dead then
		--game.logPlayer(self.summoner, "#PINK#%s vanishes.", self.name:capitalize())
		self:die()
	end
	if self.temporary then
		self.summon_time = self.summon_time - 1
	else
		self.summon_time = math.min(999, self.summon_time + 1)
	end

	-- make sure no one has turned us against our summoner
	if self.isMySummoner and self:isMySummoner(self.ai_target.actor) then
		clearTarget(self)
	end

	if self.eyelement and not self.in_combat then
		self:removeEffect(self.REK_HEKA_EYELEMENT_EYE)
		self.eyelement = nil
	end
	if self.in_combat and self.eyelemental and not self.eyelement then
		self.eyelement = rng.table({DamageType.PHYSICAL, DamageType.MIND,
																DamageType.FIRE, DamageType.LIGHT, DamageType.COLD, DamageType.DARKNESS,
																DamageType.ACID, DamageType.NATURE, DamageType.BLIGHT,
																DamageType.ARCANE, DamageType.TEMPORAL,
																DamageType.LIGHTNING})
		self:setEffect(self.REK_HEKA_EYELEMENT_EYE, 10, {element=self.eyelement, resist=self.eyelemental, src=self})
	end

	-- emergency heal
	if self.life < self.max_life * 0.3 then
		self.ai_state.stare_down = nil
		local geff = game.level.map:hasEffectType(self.x, self.y, DamageType.COSMETIC)
		if geff and geff.src == self then
			game.level.map:removeEffect(geff)
		end
		--game.logPlayer(self.summoner, "#PINK#%s needs emergency healing.", self.name:capitalize())
		if self.ai_target.actor and not self.ai_target.actor.dead then
			--game.logPlayer(self.summoner, "#PINK#%s has existing target.", self.name:capitalize())
			if eyeMoveToActorTarget(self) then
				return true
			end
		elseif eyeChooseActorTarget(self) then
			--game.logPlayer(self.summoner, "#PINK#%s chose new target.", self.name:capitalize())
			-- start moving to the target
			if eyeMoveToActorTarget(self) then
				return true
			end
		end
	end
	
	-- stare down
	if self.ai_state.stare_down then
		--game.logPlayer(self.summoner, "#PINK#%s using stare down.", self.name:capitalize())
		self.ai_state.stare_down_time = self.ai_state.stare_down_time - 1
		if self.ai_state.stare_down_time <= 0 then
			--game.logPlayer(self.summoner, "#PINK#%s stare has timed out.", self.name:capitalize())
			self.ai_state.stare_down = nil
			local geff = game.level.map:hasEffectType(self.x, self.y, DamageType.COSMETIC)
			if geff and geff.src == self then
				game.level.map:removeEffect(geff)
			end
		else
			--game.logPlayer(self.summoner, "#PINK#%s still has time on stare.", self.name:capitalize())
			if self:useTalent(self.T_REK_HEKA_EYE_STAREDOWN, nil, nil, true, self.ai_state.stare_down_target, true) then
				--game.logPlayer(self.summoner, "#PINK#%s stare down cast successfully.", self.name:capitalize())
				return true
			end
		end
	end

	-- out of summoner range?
	if core.fov.distance(self.x, self.y, self.summoner.x, self.summoner.y) > self.ai_state.summoner_range then
		--game.logPlayer(self.summoner, "#PINK#%s is out of range.", self.name:capitalize())

		clearTarget(self)

		-- phase door into range
		self:useTalent(self.T_REK_HEKA_EYE_PHASE_DOOR)
		--game.logPlayer(self.summoner, "#PINK#%s -> phase door", self.name:capitalize())
		return true
	end

	-- out of time on current target?
	if (self.turns_on_target or 0) >= 10 then
		--game.logPlayer(self.summoner, "#PINK#%s is out of time for target.", self.name:capitalize())

		clearTarget(self)
	end

	-- move to live target?
	if self.ai_target.actor and not self.ai_target.actor.dead then
		if eyeMoveToActorTarget(self) then
			return true
		end
	end

	-- move to location target?
	if self.ai_target.x and self.ai_target.y then
		if eyeMoveToLocationTarget(self) then
			return true
		end
	end

	-- no current target..start a new action
	clearTarget(self)

	-- choose an actor target? this determines their aggressiveness
	if rng.percent(65) and eyeChooseActorTarget(self) then
		--game.logPlayer(self.summoner, "#PINK#%s choose an actor.", self.name:capitalize())

		-- start moving to the target
		if eyeMoveToActorTarget(self) then
			return true
		end
	end

	-- choose a location target?
	if eyeChooseLocationTarget(self) then
		--game.logPlayer(self.summoner, "#PINK#%s choose a location.", self.name:capitalize())

		if eyeMoveToLocationTarget(self) then
			return true
		end
	end

	-- fail
	--game.logPlayer(self.summoner, "#PINK#%s -> failed to make a move.", self.name:capitalize())
	return true
end)
