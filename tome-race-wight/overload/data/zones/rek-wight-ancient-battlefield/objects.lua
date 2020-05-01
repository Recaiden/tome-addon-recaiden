load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ define_as = "CLOAK_DECEPTION",
	   power_source = {arcane=true},
	   unique = true, quest=true,
	   slot = "CLOAK",
	   type = "armor", subtype="cloak",
	   unided_name = "black cloak", image = "object/artifact/black_cloak.png",
	   moddable_tile = "cloak_%s_05", moddable_tile_hood = true,
	   name = "Cloak of Deception",
	   display = ")", color=colors.DARK_GREY,
	   encumber = 1,
	   desc = [[A black cloak, with subtle illusion enchantments woven into its very fabric.]],
	   
	   wielder = {
	      combat_spellpower = 5,
	      combat_mindpower = 5,
	      combat_dam = 5,
	   },
	   
	   on_wear = function(self, who)
	      if game.party:hasMember(who) then
		 for m, _ in pairs(game.party.members) do
		    m:setEffect(m.EFF_CLOAK_OF_DECEPTION, 1, {})
		 end
		 game.logPlayer(who, "#LIGHT_BLUE#An illusion appears around %s, making them appear human.", who.name:capitalize())
	      end
	   end,
	   on_takeoff = function(self, who)
	      if self.upgraded_cloak then return end
	      if game.party:hasMember(who) then
		 for m, _ in pairs(game.party.members) do
		    m:removeEffect(m.EFF_CLOAK_OF_DECEPTION, true, true)
		 end
		 game.logPlayer(who, "#LIGHT_BLUE#The illusionary covering %s disappears", who.name:capitalize())
	      end
	   end,
}

for i = 1, 2 do
   newEntity{ base = "BASE_LORE",
	      define_as = "NOTE"..i,
	      name = "crumpled note", lore="kidnapper-hideout-note-"..i,
	      desc = [[Instructions from the ringleader to his thugs.]],
	      rarity = false,
   }
end
