local p = game.party:findMember{main=true}
-- Mummies skip down to the bottom, others enter at the top
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
   name="Entrance to a half-buried pyramid",
   color=colors.GREY,
   add_displays = {class.new{image="terrain/mummy_pyramid.png", z=8, display_h=1, display_y=0}},
   change_zone = "mummy-crypt-ruins",
}
end
