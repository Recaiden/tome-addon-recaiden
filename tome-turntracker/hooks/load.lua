class:bindHook('UISet:Minimalist:saveSettings', function(self, data)
  local l = data.lines
  -- Spectacularly Dodgy Hack(TM) by zizzo
  l[#l+1] = 'tome.uiset_minimalist.addon = tome.uiset_minimalist.addon or {}'
  l[#l+1] = 'tome.uiset_minimalist.addon.turntracker = {}'
  l[#l+1] = 'tome.uiset_minimalist.addon.turntracker.places = {}'
  if self.places.turntracker then
    for k, v in pairs(self.places.turntracker) do
      l[#l+1] = ('tome.uiset_minimalist.addon.turntracker.places.%s = %f'):format(k, v)
    end
  end
end)
