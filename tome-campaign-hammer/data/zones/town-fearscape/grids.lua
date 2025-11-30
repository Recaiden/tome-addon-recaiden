load("/data/general/grids/malrok_walls.lua")
load("/data/general/grids/lava.lua")
load("/data/general/grids/void.lua", function(e) if e.image then e.image = e.image:gsub("^terrain/floating_rocks", "terrain/red_floating_rocks") end end)
load("/data/general/grids/burntland.lua", function(e) if e.image == "terrain/grass_burnt1.png" then e.image = "terrain/red_floating_rocks05_01.png" end end)

newEntity{
	define_as = "CRATER",
	type = "floor", subtype = "rocks",
	name = "impact crater", image = "terrain/red_floating_rocks05_01.png",
	add_displays = {
		class.new{z=4, image="terrain/impact_crater_lava.png", display_w=4, display_h=4, display_x=-1.5, display_y=-1.5},
	},
	display = '*', color_r=255, color_g=255, color_b=0,
	_noalpha = false,
}

newEntity{
	define_as = "PORTAL_EYAL", 
	type = "floor", subtype = "floor",
	name = "portal to Eyal",
	image = "terrain/red_floating_rocks05_01.png", add_displays = {
		class.new{z=3, image="terrain/planar_demon_portal_ground_down.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2},
		class.new{z=16, image="terrain/planar_demon_portal_ground_up.png", display_x=-0.5, display_y=-0.5, display_w=2, display_h=2},
	},
	on_added = function(self, level, x, y)
		local ps = self.add_displays[1]:addParticles(require("engine.Particles").new("farportal_vortex", 1, {rot=3, size=42, vortex="shockbolt/terrain/planar_demon_vortex"}))
		ps.dy = -0.05
	end,
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1, change_zone = "wilderness",
}

newEntity{
	define_as = "DEMON_VAULT_FLOOR",
	type = "floor", subtype = "rocks",
	name = "storage-safe floor", image = "terrain/red_floating_rocks05_01.png",
	display = '.', color_r=255, color_g=255, color_b=255, back_color=colors.DARK_GREY,
	grow = "MALROK_WALL",
	on_added = function(self, level, x, y)
		game.level.map.attrs(x, y, "no_decay", true)
	end,
}

newEntity{
	define_as = "DEMON_ITEMS_VAULT",
	name = "Item's Vault Control Orb", image = "terrain/red_floating_rocks05_01.png", add_displays = {class.new{z=18, image="terrain/pedestal_orb_02.png", display_y=-1, display_h=2}},
	display = '*', color=colors.LIGHT_BLUE,
	notice = true,
	always_remember = true,
	block_move = function(self, x, y, e, act, couldpass)
		if e and e.player and act then
			local chat = nil
			if not game:isAddonActive("items-vault") then
				game.logPlayer(game.player, "The item vault cannot reach into your universe.")
				return true
			end
			if game.player.level < 20 then
				game.logPlayer(game.player, "The item vault isn't powered up yet.  Come back later (level 20+).")
				return true
			end
			if profile:isDonator() and (not profile.connected or not profile.auth) then
				chat = require("engine.Chat").new("items-vault-command-orb-offline", self, e, {player=e})
			elseif profile:isDonator() then
				chat = require("engine.Chat").new("items-vault-command-orb", self, e, {player=e})
			else
				return true
			end
			chat:invoke()
		end
		return true
	end,
}

load("/data/zones/shertul-fortress/grids.lua", function(e)
	if e.define_as == "TRAINING_ORB" then
		e.image = "terrain/red_floating_rocks05_01.png"
	elseif e.define_as == "MONITOR_ORB1" or e.define_as == "MONITOR_ORB2" then
		e.image = "terrain/red_floating_rocks05_01.png"
	end
end)

newEntity {
  define_as = 'BASE_ROD_PEDESTAL',
  name = 'anchor pedestal',
  special = true, 
  -- Child entities should replace this with a floor matching the target
  -- zone.
  image = 'terrain/marble_floor.png',
  add_displays = {
    class.new {
      image = 'terrain/pedestal_orb_05.png',
      display_h = 2,
      display_y = -1,
      z = 18,
    }
  },
  display = "_",
  color = colors.WHITE,
  back_color = colors.LIGHT_RED,
  always_remember = true,
  special_minimap = colors.SALMON,
  notice = true,
  block_move = function(self, x, y, who, act, couldpass)
    if who and who.player and act and self.recall_target then
      local Dialog = require 'engine.ui.Dialog'
      local Map = require 'engine.Map'
      local title = _t'Strange Pedestal'
      if who:findInAllInventoriesBy('define_as', 'ROD_OF_RECALL') then
	local function cb(ok)
	  if ok then
	    local rod = who:findInAllInventoriesBy('define_as', 'ROD_OF_RECALL')
	    if rod then
	      rod.recall_target = self.recall_target
	    end
	  end
	end
	local txt = _t[[As you approach the pedestal, your Rod of Recall begins vibrating.  The pedestal has a long slot on the top that would fit the Rod, with a caption underneath that you understand as "Set Anchor".  It looks like you could use this pedestal to anchor your Rod of Recall to this place, so that it would return you here instead of to the wilderness.

Do you wish to anchor your Rod of Recall?]]
	Dialog:yesnoLongPopup(title, txt, 400, cb)
      else
	local txt = _t[[This pedestal has a long slot on the top that looks like it would fit a rod of some sort, with a caption underneath that you understand as "Set Anchor".  Looking at the pedestal, you feel as though you are missing something...]]
	Dialog:simpleLongPopup(title, txt, 400)
      end
    end
    return true
  end,
}

newEntity {
  base = 'BASE_ROD_PEDESTAL',
  define_as = 'HAMMER_ROD_PEDESTAL',
  image = 'terrain/red_floating_rocks05_01.png',
  back_color = colors.LIGHT_RED,
  recall_target = 'campaign-hammer+town-fearscape',
}
