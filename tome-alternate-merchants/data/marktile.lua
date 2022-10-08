load("/data/general/grids/basic.lua")
load("/data/general/grids/burntland.lua")

newEntity{ base = "ALTAR",
	define_as = "ALTAR_CORRUPT",
	on_move = function(self, x, y, who)
		if not who.player then return end
		local o, item, inven = who:findInAllInventoriesBy("define_as", "SANDQUEEN_HEART")

		-- original heart corruption
		if o then
			require("engine.ui.Dialog"):yesnoPopup(
				_t"Heart of the Sandworm Queen", _t"The altar seems to react to the heart. You feel you could corrupt it here.",
				function(ret)
					if ret then return end
					local o = game.zone:makeEntityByName(game.level, "object", "CORRUPTED_SANDQUEEN_HEART", true)
					if o then
						who:removeObject(inven, item, true)
						o:identify(true)
						who:addObject(who.INVEN_INVEN, o)
						who:sortInven(who.INVEN_INVEN)
						game.log("#GREEN#You put the heart on the altar. The heart shrivels and shakes, vibrating with new corrupt forces.")
					end
				end, _t"Cancel", _t"Corrupt", nil, true)
			return
		end
		
		if who.money and who.money > (750 * (game.player.__game_difficulty or 2)) then
			require("engine.ui.Dialog"):yesnoPopup(
				_t"Hellforge", _t"The altar seems to react to your vast stores of gold.  You could shape an item here.",
				function(ret)
					if ret then return end

					local Chat = require "engine.Chat"
					local chat = Chat.new("alternate-merchants+demon-forge", self, game:getPlayer(true))
					chat:invoke()
				end, _t"Cancel", _t"Forge", nil, true)
			
		end
		
	end,
}
