newBirthDescriptor {
  type = 'subrace',
  name = 'Mummy',
  locked = function()
     return profile.mod.allow_build.undead_mummy
     --return profile.mod.allow_build.undead_ghoul or profile.mod.allow_build.undead_skeleton
  end,	
  locked_desc = "Grasping arms, wrapped up tight, death won't pierce eternal night!",
  desc = {
     "Mummies are willful (if clumsy) preserved undead creatures, hard to disable.",
     "They have access to #GOLD#special mummy talents#WHITE# and a wide range of undead abilities:",
     "- great poison resistance",
     "- bleeding immunity",
     "- no need to breathe",
     "- fear immunity",
     "- special talents: entangle, inevitability, and canopic jars",
     '#GOLD#Stat modifiers:',
     '#LIGHT_BLUE# * +3 Strength, -3 Dexterity, +0 Constitution',
     '#LIGHT_BLUE# * +2 Magic, +3 Willpower, +0 Cunning',
     '#GOLD#Life per level:#LIGHT_BLUE# 12',
     '#GOLD#Experience penalty:#LIGHT_BLUE# +20%'},
  moddable_attachement_spots = "race_ghoul",
  moddable_attachement_spots_sexless=true,
  descriptor_choices =
     {
	sex =
	   {
	      __ALL__ = "disallow",
	      Male = "allow",
	   },
     },
  inc_stats = { str = 3, dex = -3, con = 0, mag = 2, wil = 3, cun = 0 },
  experience = 1.2,
  talents_types = {
     ["undead/mummy"]={true, 0.1},
     ["undead/mummified"]={true, 0.1},
  },
  talents = {
     [ActorTalents.T_MUMMY_EMBALM]=1,
     --[ActorTalents.T_MUMMY_FIRE_WEAKNESS]=1, --no longer needed
  },
  copy = {
     type = "undead", subtype="mummy",
     default_wilderness = {"playerpop", "mid-undead"},
     starting_intro = "mummy",
     life_rating=12,
     poison_immune = 0.8,
     resists = { [engine.DamageType.FIRE] = -50, },
     cut_immune = 1,
     fear_immune = 1,
     no_breath = 1,
     global_speed_base = 1.0,
     moddable_tile = "ghoul",
     moddable_tile_base = "base_mummy.png",
     moddable_tile_nude = 1,
     starting_zone = "town-crypt",
     starting_level = 1,
     --starting_zone = "ruined-crypt",
     --starting_level = 3, starting_level_force_down = true,
     starting_quest = "start-mummy",

     --resolvers.inventory({id=true,
--			  transmo=false,
--			  {type="armor", subtype="mummy",
--			   name="mummy wrappings",
--			   ego_chance=-1000}}),
    } 
}

getBirthDescriptor("race", "Undead").descriptor_choices.subrace['Mummy'] = "allow"
