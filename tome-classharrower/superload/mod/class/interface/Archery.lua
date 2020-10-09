local _M = loadPrevious(...)

_M.base_archery_projectile = _M.archery_projectile
local function archery_projectile(tx, ty, tg, self, tmp)
	local target = game.level.map(tx, ty, game.level.map.ACTOR)
	if not target then return end

	if self:knowTalent(self.T_REK_GLR_MARKSMAN_PINPOINT) then
		local bonus = util.bound(self:combatAttack() - target:combatDefense(), 0, 80)
		local mult = bonus * 2.5 / 100
		if tg.archery.proc_mult then
			tg.archery.proc_mult = tg.archery.proc_mult * (1+mult)
		else
			tg.archery.proc_mult = 1+mult
		end
	end
	
	return self.base_archery_projectile(tx, ty, tg, self, tmp)
end
_M.archery_projectile = archery_projectile

-- entire original function
function _M:archeryShoot(targets, talent, tg, params, force)
	params = params or {}
	-- some extra safety checks
	if self:attr("disarmed") then
		game.logPlayer(self, "You are disarmed!")
		return nil
	end
	local weapon, ammo, offweapon, pf_weapon = self:hasArcheryWeapon(params.type)

	if force and force.mainhand then weapon = force.mainhand end
	if force and force.offhand then offweapon = force.offhand end
	if force and force.ammo then ammo = force.ammo end

	if not weapon and not pf_weapon then
		game.logPlayer(self, "You must wield a ranged weapon (%s)!", ammo)
		return nil
	end
	print("[ARCHERY SHOOT]", self.name, self.uid, "using weapon:", weapon and weapon.name, "ammo:", ammo and ammo.name, "offweapon:", offweapon and offweapon.name, "pf_weapon:", pf_weapon and pf_weapon.name)
	local weaponC, offweaponC, pf_weaponC = weapon and weapon.combat, offweapon and offweapon.combat, pf_weapon and pf_weapon.combat

	local tg = tg or {}
	tg.talent = tg.talent or talent
	
	-- Pass friendly actors
	if self:attr("archery_pass_friendly") or self:knowTalent(self.T_SHOOT_DOWN) then
		tg.friendlyfire=false	
		tg.friendlyblock=false
	end

	-- hook to trigger before any archery projectiles are created
	self:triggerHook{"Combat:archeryTargetKind", tg=tg, params=params, weapon=weaponC, offweapon=offweaponC, pf_weapon=pf_weaponC, ammo=ammo, mode="fire"}

	-- create a projectile for each target on the list
	local dofire = function(weapon, targets, realweapon)

		for i = 1, #targets do
			local tg = table.clone(tg) -- prevent overwriting params from different shooter/ammo combinations
			tg.archery = table.clone(params)
			tg.archery.weapon = weapon
			tg.archery.ammo = targets[i].ammo or ammo.combat
			-- calculate range, speed, type by shooter/ammo combination
			tg.range = math.min(tg.range or 40, math.max((self.archery_bonus_range or 0) + weapon.range or 6, self:attr("archery_range_override") or 1))
			tg.speed = (tg.speed or 10) + (ammo.travel_speed or 0) + (weapon.travel_speed or 0) + (self.combat and self.combat.travel_speed or 0)
			tg.type = tg.type or weapon.tg_type or tg.archery.ammo.tg_type or "bolt"
			tg.display = tg.display or targets[i].display or self:archeryDefaultProjectileVisual(realweapon, ammo)
		
			tg.archery.use_psi_archery = self:attr("use_psi_combat") or weapon.use_psi_archery
			print("[ARCHERY SHOOT dofire] Shooting weapon:", realweapon and realweapon.name, "to:", targets[i].x, targets[i].y)
			if realweapon.on_archery_trigger then realweapon.on_archery_trigger(realweapon, self, tg, params, targets[i], talent) end -- resources must be handled by the weapon function
			-- hook to trigger as each archery projectile is created
			local hd = {"Combat:archeryFire", tg=tg, archery = tg.archery, weapon=weapon, realweapon = realweapon, ammo=ammo}
			self:triggerHook(hd)
			local proj = self:projectile(tg, targets[i].x, targets[i].y, self.archery_projectile)
		end
	end

	if weapon and not offweapon and not targets.dual then
		dofire(weaponC, targets, weapon)
	elseif weapon and offweapon and targets.dual then
		dofire(weaponC, targets.main, weapon)
		dofire(offweaponC, targets.off, offweapon)
	else
		print("[SHOOT] error, mismatch between dual weapon/dual targets")
	end
	if pf_weapon and targets.psi then
		local combat = table.clone(pf_weaponC)
		combat.use_psi_archery = true -- psionic focus weapons always use psi combat
		dofire(combat, targets.psi, pf_weapon)
	end
end

return _M