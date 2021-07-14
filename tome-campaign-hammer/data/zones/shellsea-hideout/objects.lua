load("/data/general/objects/objects-maj-eyal.lua")
load("/data/general/objects/objects-far-east.lua")

newEntity{
	base = "BASE_ROD", define_as = "WAND_WALROG_QUEST",
	power_source = {unknown=true},
	unided_name = _t"coral rod",
	name = "Walrog's Draining Wand", color=colors.LIGHT_RED, unique=true, image = "object/artifact/wand_gwais_burninator.png",
	desc = _t[[This wand can extract the vim of a creature close to death, stealing their life energy to revitalise another.  It is attuned to Walrog, and cannot be used to heal anyone else.]],
	cost = 300,
	rarity = false,
	level_range = {25, 35},
	add_name = false,
	material_level = 1,
	max_power = 10, power_regen = 0,
	carrier = {
		combat_spellpower = 10,
	},
	use_power = {
		power=1, name=_t"steal life from a weakened creature", no_npc_use = true, use = function(self, who, inven, item)
			local tg = {type="hit", nowarning=true, range=7}
			local tx, ty, target = who:getTarget(tg)
			if not tx or not ty then return nil end
			local _ _, _, _, tx, ty = who:canProject(tg, tx, ty)
			target = game.level.map(tx, ty, engine.Map.ACTOR)
			if target == who then target = nil end
			if not target then return nil end
			if target.type == "undead" then
				game.logPlayer(who, "#CRIMSON#That creature is already dead!")
				return nil
			end
			if target.life / target.max_life > 0.3 then
				game.logPlayer(who, "#CRIMSON#That creature is not hurt enough to drain.")
				return nil
			end
			
			game.logPlayer(who, "#AQUAMARINE#Your victim's life drains away, flowing through the wand to Walrog.")
			game.bignews:saySimple(180, "#AQUAMARINE#Your victim's life drains away, flowing through the wand to Walrog.")
			target:disappear()
			who:hasQuest("campaign-hammer+demon-allies"):walrog_capture(who)
			return {used=true, id=true}
	end},
}
