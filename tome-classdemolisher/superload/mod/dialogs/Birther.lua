local Particles = require "engine.Particles"

local _M = loadPrevious(...)

_M.cosmetic_options_config["steel_rider"] = "single"
_M.cosmetic_options_config["drones"] = "single"

local base_applyCosmeticActor = _M.applyCosmeticActor
function _M:applyCosmeticActor(last)
	local cosmetics = self.selected_cosmetic_options or {}
	base_applyCosmeticActor(self, last)
	if not last then
		for kind, d in pairs(cosmetics) do
			if d.preview_particles then
				for _, particle in pairs(d.preview_particles) do
					self.actor:addParticles(Particles.new(particle.particle, 1, particle.args))
				end
			end
		end
	end
end
return _M
