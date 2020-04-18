newBirthDescriptor{
   type = "difficulty",
   name = "Custom",
   selection_default = (config.settings.tome.default_birth and config.settings.tome.default_birth.difficulty == "Normal") or (not config.settings.tome.default_birth) or (config.settings.tome.default_birth and not config.settings.tome.default_birth.difficulty),
   desc =
      {
	 "#GOLD##{bold}#Normal mode#WHITE##{normal}#",
	 "Provides the normal level of challenges.",
	 "Stairs can not be used for 2 turns after a kill.",
      },
   descriptor_choices =
      {
	 race = { ["Tutorial Human"] = "forbid", },
	 class = { ["Tutorial Adventurer"] = "forbid", },
      },
   copy = {
      instakill_immune = 1,
      __game_difficulty = 2,
   },
   talents = {
      [ActorTalents.T_HUNTED_PLAYER] = 1,
   },
   rek_dif_talents_backup = {
      [ActorTalents.T_HUNTED_PLAYER] = 1,
   },
}
