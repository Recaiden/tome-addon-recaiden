local p = game.party:findMember{main=true}
-- Mummies skip down to the bottom, others are stuck outside
if p.descriptor and p.descriptor.race and p.descriptor.subrace == "Mummy"
then
   newEntity{
   base="ZONE_PLAINS", define_as = "MUMMY_CRYPT",
   name="Entrance to a half-buried pyramid",
   color=colors.GREY,
   add_displays = {class.new{image="terrain/mummy_pyramid.png", z=8, display_h=1, display_y=0}},
   change_zone = "town-crypt",
}
else
   newEntity{
   base="ZONE_PLAINS", define_as = "MUMMY_CRYPT",
   name="Sealed, half-buried pyramid",
   color=colors.GREY,
   add_displays = {class.new{image="terrain/mummy_pyramid.png", z=8, display_h=1, display_y=0}},
   change_zone = "town-crypt",
   change_level_check = function()
      local p = game.party:findMember{main=true}
      if p.descriptor and p.descriptor.race and p.descriptor.subrace == "Mummy" then
         return false
      end
      if p:knowTalent(p.T_MUMMY_EMBALM) then
         return false
      end
      require("engine.ui.Dialog"):simplePopup("Pyramid", "Try as you might, you are unable to breach the entrance.  It can only be opened from inside.")
      return true
   end,
            }
end
