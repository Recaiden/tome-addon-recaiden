local _M = loadPrevious(...)

local Particles = require "engine.Particles"

local eyeless = {
		["npc/horror_corrupted_dremling.png"] = true,
		["npc/horror_corrupted_drem_master.png"] = true,
		["npc/horror_corrupted_drem.png"] = true,
		["npc/horror_corrupted_the_mouth.png"] = true,
		["npc/horror_eldritch_eldritch_eye.png"] = true,
		["npc/horror_eldritch_headless_horror.png"] = true,
		["npc/horror_eldritch_maelstrom.png"] = true,
		["npc/horror_eldritch_weirdling_beast.png"] = true,
		["npc/horror_sher_tul_caldizar.png"] = true,
		["npc/horror_sher_tul_fortress_shadow.png"] = true,
		["npc/god_eyal_amakthel_s_eye_closed.png"] = true,
		["npc/god_eyal_amakthel_s_eye.png"] = true,
		["npc/god_eyal_amakthel_s_hand_closed.png"] = true,
		["npc/god_eyal_amakthel_s_hand.png"] = true,
		["npc/god_eyal_amakthel_s_mouth_closed.png"] = true,
		["npc/god_eyal_amakthel_s_mouth.png"] = true,
		["npc/horror_eldritch_eyed_tentacle.png"] = true,
		["npc/horror_eldritch_oozing_tentacle.png"] = true,
		["npc/horror_eldritch_saw_horror.png"] = true,
		["npc/horror_eldritch_spiked_tentacle.png"] = true,
		["npc/horror_shertul_shertul_high_priest_eye_infused.png"] = true,
		["npc/horror_shertul_shertul_high_priest_hand_infused.png"] = true,
		["npc/horror_shertul_shertul_high_priest_mouth_infused.png"] = true,
		["npc/horror_shertul_sher_tul_high_priest.png"] = true
}

local customEyes = {
	["npc/vermin_worms_carrion_worm_mass.png"] = {
		{ x = 8, y = 19 },
		{ x = 17, y = 20 },
		{ x = 4, y = 37 },
		{ x = 14, y = 38 },
	},
	["npc/horror_corrupted_the_abomination.png"] = {
		{ x = 21, y = -38 },
		{ x = 27, y = -40 },
		{ x = 45, y = -32 },
		{ x = 51, y = -31 },
	},
	["npc/giant_steam_steam_giant_yeti_rider.png"] = {
		{ x = 9, y = 14 },
		{ x = 14, y = 14 },
		{ x = 31, y = -31 },
		{ x = 36, y = -32 },
	},
	["npc/summoner_hydra.png"] = {
		{ x = 4, y = 14 },
		{ x = 13, y = 14 },
		{ x = 27, y = 8 },
		{ x = 34, y = 8 },
		{ x = 37, y = 26 },
		{ x = 45, y = 25 },
	}
}

function _M:updateGooglyEyes()
	local as = self.attachement_spots or self.image
	if eyeless[as] then return end
	if customEyes[as] then
		if self.__googly_particles then
			for _, particle in pairs(self.__googly_particles) do
				self:removeParticles(particle)
			end
			self.__googly_particles = nil
		end
		self.__googly_particles = {}
		for _, location in pairs(customEyes[as]) do
			self.__googly_particles[#self.__googly_particles+1] = self:addParticles(Particles.new("level_circle", 0.15, {x=(location.x) * (self._flipx and -1 or 1)-32, y=location.y-32, oversize=0.15, a=255, speed=0, img="googl", radius=0}))
		end
		
		return
	end

	if self.__googly_particles then
		self:removeParticles(self.__googly_particles[1])
		self:removeParticles(self.__googly_particles[2])
		self.__googly_particles = nil
	end
	
	local bx, by, offset, offsetV
	bx, by = self:attachementSpot("head", true)
	offset = 6
	offsetV = 0
	if not bx then
		bx = 0
		by = 0 ---0.3
		offset = 8
		offsetV = -3
	end
	self.__googly_particles = {
		self:addParticles(Particles.new("level_circle", 0.15, {x=(bx*64-offset) * (self._flipx and -1 or 1), y=by*64+offsetV, oversize=0.15, a=255, speed=0, img="googl", radius=0})),
		self:addParticles(Particles.new("level_circle", 0.15, {x=(bx*64+offset) * (self._flipx and -1 or 1), y=by*64+offsetV, oversize=0.15, a=255,  speed=0, img="googl", radius=0}))
	}
	--TODO extra eyes for spiders no eyes for headless enemies, etc.
end

local MOflipX = _M.MOflipX
function _M:MOflipX(v)
	local oldflip = self._flipx
	MOflipX(self, v)
	
	if v ~= oldflip then
		self:updateGooglyEyes()
	end
end

local base_umtp = _M.updateModdableTilePrepare
function _M:updateModdableTilePrepare()
	self:updateGooglyEyes()
	
	return base_umtp(self)
end

return _M
