load("/data/general/traps/natural_forest.lua")
load("/data/general/traps/store.lua")

newEntity{ base = "BASE_STORE", define_as = "BARRED_DOOR",
	name="Door to the Castle",
	display='*', color=colors.UMBER, image = "store/shop_door_barred.png",
}
