---------------------------------------------------------------------
-- THIS IS NOT TO BIRTH WITH
---------------------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Dread",
	locked = function() return true end,
	locked_desc = _t"You should not see this!",
	desc = {
	},
	moddable_attachement_spots = "race_skeleton", moddable_attachement_spots_sexless=true,
	copy = {
		moddable_tile = "skeleton",
		moddable_tile_base = "base_lich_01.png",
		moddable_tile_nude = 1,
	},
	cosmetic_options = {
		skin = {
			{name=_t"Skin Color 1", file="base_lich_01"},
			{name=_t"Skin Color 2", file="base_lich_02"},
			{name=_t"Skin Color 3", file="base_lich_03"},
			{name=_t"Skin Color 4", file="base_lich_04"},
			{name=_t"Skin Color 5", file="base_lich_05"},
			{name=_t"Skin Color 6", file="base_lich_06"},
			{name=_t"Skin Color 7", file="base_lich_07"},
			{name=_t"Skin Color 8", file="base_lich_08"},
		},
		hairs = {
			{name=_t"Hair 1", file="hair_01"},
			{name=_t"Hair 2", file="hair_02"},
			{name=_t"Redhead Hair 1", file="hair_redhead_01", unlock="cosmetic_race_human_redhead"},
			{name=_t"Redhead Hair 2", file="hair_redhead_02", unlock="cosmetic_race_human_redhead"},
			{name=_t"White Hair 1", file="hair_white_01"},
			{name=_t"White Hair 2", file="hair_white_02"},
		},
		facial_features = {
			{name=_t"Beard 1", file="beard_01"},
			{name=_t"Beard 2", file="beard_02"},
			{name=_t"Redhead Beard 1", file="beard_redhead_01", unlock="cosmetic_race_human_redhead"},
			{name=_t"Redhead Beard 2", file="beard_redhead_02", unlock="cosmetic_race_human_redhead"},
			{name=_t"White Beard 1", file="beard_white_01"},
			{name=_t"White Beard 2", file="beard_white_02"},
			{name=_t"Eyes 1", file="face_eyes_01"},
			{name=_t"Eyes 2", file="face_eyes_02"},
			{name=_t"Eyes 3", file="face_eyes_03"},
			{name=_t"Mustache", file="face_mustache_01"},
			{name=_t"Redhead Mustache", file="face_mustache_redhead_01", unlock="cosmetic_race_human_redhead"},
			{name=_t"White Mustache", file="face_mustache_white_01"},
			{name=_t"Teeth 1", file="face_teeth_01"},
			{name=_t"Teeth 2", file="face_teeth_02"},
			{name=_t"Lich Eyes 1", file="face_lich_eyes_01"},
			{name=_t"Lich Eyes 2", file="face_lich_eyes_02"},
			{name=_t"Lich Eyes 3", file="face_lich_eyes_03"},
		},
		tatoos = {
			{name=_t"Cracks", file="tattoo_cracks"},
			{name=_t"Guts", file="tattoo_guts"},
			{name=_t"Iron Bolt", file="tattoo_iron_bolt"},
			{name=_t"Molds", file="tattoo_mold_01"},
			{name=_t"Runes 1", file="tattoo_runes_01"},
			{name=_t"Runes 2", file="tattoo_runes_02"},
			{name=_t"Rust", file="tattoo_rust_01"},
		},
	},
}