-- copy of vanilla ring imbuing
local imbueEgo = function(gem, ring)
	if not gem then return end
	if not ring then return end
	local Entity = require("engine.Entity")
	local ego = Entity.new{
		fake_ego = true,
		name = "imbued_"..gem.name,
		keywords = {[gem.name] = true},
		wielder = table.clone(gem.imbue_powers, true),
		been_imbued = true,
		egoed = true,
		shop_gem_imbue=true,
	}
	if gem.talent_on_spell then ego.talent_on_spell = table.clone(gem.talent_on_spell, true) end
	game.zone:applyEgo(ring, ego, "object", true)
end

local imbue_ring = function(npc, player)
	player:showInventory(_t"Imbue which ring?", player:getInven("INVEN"), function(o) return o.type == "jewelry" and o.subtype == "ring" and o.material_level and not o.unique and not o.plot and not o.special and not o.tinker and not o.shop_gem_imbue end, function(ring, ring_item)
		player:showInventory(_t"Use which gem?", player:getInven("INVEN"), function(gem) return gem.type == "gem" and gem.imbue_powers and gem.material_level end, function(gem, gem_item)
			game:chronoCancel(_t"#CRIMSON#Your timetravel has no effect on pre-determined outcomes such as this.")

			local lev = (ring.material_level + gem.material_level) / 2 * 10 + 10
			local new_ring
			local r = rng.range(0, 99)
			if r < 20 then
				local ring = game.zone:makeEntity(game.level, "object", 
					{base_list="mod.class.Object:/data/general/objects/jewelry.lua", type="jewelry", subtype="ring",
					ignore_material_restriction=true, ego_filter={keep_egos=true, ego_chance=-1000},
					special=function(e) return e.material_level == ring.material_level end}
					, lev, true)
				new_ring = game.state:generateRandart{base=ring, lev=lev}
			else
				new_ring = game.zone:makeEntity(game.level, "object",
					{base_list="mod.class.Object:/data/general/objects/jewelry.lua", type="jewelry", subtype="ring",
					ignore_material_restriction=true, tome = {greater=9, double_greater=1}, egos = 2,
					special=function(e) return e.material_level == ring.material_level end}
					, lev, true)
			end
			if not new_ring then
				game.logPlayer(player, "%s failed to craft with %s and %s!", npc.name:capitalize(), ring:getName{do_colour=true, no_count=true}, gem:getName{do_colour=true, no_count=true})
				return false
			end
			
			local price = 200 * (ring.material_level + gem.material_level) / 2
			if gem.unique then price = price * 1.5 end
			if price > player.money then require("engine.ui.Dialog"):simplePopup(_t"Not enough money", ("This costs %d gold, you need more gold."):tformat(price)) return end

			require("engine.ui.Dialog"):yesnoPopup(_t"Imbue cost", ("This will cost you %s gold, do you accept?"):tformat(price), function(ret) if ret then
				imbueEgo(gem, new_ring)
				player:incMoney(-price)
				player:removeObject(player:getInven("INVEN"), gem_item)

				new_ring.name = ("%s %s ring"):tformat(_t(ring.short_name) or _t(ring.name) or _t"weird", _t(gem.name))
				new_ring:identify(true)
				ring:replaceWith(new_ring)
				game.zone:addEntity(game.level, ring, "object")

				game.logPlayer(player, "%s creates: %s", npc.name:capitalize(), new_ring:getName{do_colour=true, no_count=true})
			end end)
		end)
	end)
end


newChat{ id="welcome",
	text = _t[[Welcome @playername@.  You can buy rings and amulets at the storefront there, while I handle special orders.]],
	answers = {
		{_t"I am looking for special jewelry.", jump="jewelry"},
		{_t"Would it be possible for my Transmogrification Chest to automatically extract gems?", jump="transmo-gems", cond=function(npc, player) return not (game.state.transmo_chest_extract_gems == true) and player:attr("has_transmo") and player:knowTalent(player.T_EXTRACT_GEMS) end},
		{_t"Sorry, I have to go!"},
	}
}

newChat{ id="transmo-gems",
	text = _t[[Ah yes, I see you practice the art of alchemy. I can change the chest to automatically use your power to extract a gem if the transmogrification of the gem would reward more energy.]],
	answers = {
		{_t"Maybe sometime later."},
		{_t"That could be quite useful. Yes, please do it.", action=function()
			 game.state.transmo_chest_extract_gems = true
			 game.log("#VIOLET#Your transmogrification chest glows brightly for a moment.")
		end},
	}
}

newChat{ id="jewelry",
	text = _t[[Then you are at the right place, for I am an expert jeweler.
If you bring me a gem and a ring, I can create a new ring imbued with the properties of the gem.  The original traits of the ring will be lost in the process but new ones of similar quality will be generated.
There is a small fee dependent on the level of the ring, and you need a quality ring to use a quality gem.]],
	answers = {
		{_t"I need your services.", action=imbue_ring},
		{_t"Not now, thanks."},
	}
}

return "welcome"
