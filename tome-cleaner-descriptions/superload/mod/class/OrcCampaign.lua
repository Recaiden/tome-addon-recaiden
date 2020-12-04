_M = loadPrevious(...)
module(..., package.seeall, class.make)

function hookObjectDescPowerSource(self, data)
   if self.power_source.steam then 
      local sps = self.power_source
      if sps.arcane or sps.nature or sps.antimagic or sps.technique or sps.psionic or sps.unknown then
         data.desc:add( "/" )
      end
      data.desc:add({"color", "b6bd69"}, "Steamtech", {"color", "LAST"}) 
   end
end

function hookObjectDescWielder(self, data)
end

return _M