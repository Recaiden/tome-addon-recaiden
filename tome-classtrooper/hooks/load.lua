local class = require"engine.class"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"
local ActorResource = require "engine.interface.ActorResource"
local Birther = require "engine.Birther"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"
local Zone = require "engine.Zone"
local Map = require "engine.Map"

ActorResource:defineResource("Battery", "battery", "T_BATTERY_POOL", "battery_regen", "Your battery powers your laser carbine.  It recovers at 2 per turn after 3 turns without being used", 0, 6, {
	color = "#ff33ef#",
	wait_on_rest = true,
	status_text = function(act)
		local cooldown = act.oclt_battery_overheat
		if act.oclt_battery_overheat ~= nil then
			return ("%d/%d   (%d turns)"):tformat(act:getBattery(), act:getMaxBattery(), cooldown)
		end
		return ("%d/%d"):tformat(act:getBattery(), act:getMaxBattery())
	end,
	Minimalist = { --parameters for the Minimalist uiset
		images = {front = "resources/front_battery.png", front_dark = "resources/front_battery_dark.png"},
		highlight = function(player, vc, vn, vm, vr) return vc >=0.9*vm end,
		shader_params = {name = "resources2", require_shader=4, delay_load=true, color1={0xef/255, 0x00/255, 0x6f/255}, color2={0xff/255, 0x33/255, 0x7f/255}, amp=0.8, speed=2000, distort={0.2,0.25}}
	}
})

class:bindHook("ToME:load", function(self, data)
  Talents:loadDefinition('/data-classtrooper/talents/talents.lua')
  ActorTemporaryEffects:loadDefinition('/data-classtrooper/effects.lua')
  Birther:loadDefinition("/data-classtrooper/birth/classes/warrior.lua")
  DamageType:loadDefinition("/data-classtrooper/damage_types.lua")
end)
