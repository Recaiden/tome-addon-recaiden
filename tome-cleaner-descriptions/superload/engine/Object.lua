local _M = loadPrevious(...)

function mod_align_stat( in_str, off_mod )
   off_mod = off_mod or 0
   in_str = in_str or ""
   local attr_offs = 6
   if string.len( in_str ) < attr_offs then
      return in_str .. string.rep(" ",attr_offs - string.len( in_str )+off_mod)
   else
      return in_str .. " "
   end
end

--- Describe requirements
function _M:getRequirementDesc(who)
	local req = rawget(self, "require")
	if not req then return nil end
	local is_ctrl = core.key.modState("ctrl")
	local str = tstring{}
	local num = 0
	
	if req.flag then
		for _, flag in ipairs(req.flag) do
			if type(flag) == "table" then
				local name = self.requirement_flags_names[flag[1]] or flag[1]
				if (who:attr(flag[1]) or 0) < flag[1] then num = num + 1 end
				local c = (who:attr(flag[1]) and who:attr(flag[1]) >= flag[2]) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
				str:add(c, "- ", ("%s (level %d)"):format(name, flag[2]), {"color", "LAST"}, true)
			else
				local name = self.requirement_flags_names[flag] or flag
				if not who:attr(flag) then num = num + 1 end
				local c = who:attr(flag) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
				str:add(c, "- ", ("%s"):format(name), {"color", "LAST"}, true)
			end
		end
	end
	
   if req.stat then
      for s, v in pairs(req.stat) do
         if who:getStat(s) < v or is_ctrl then
            local c = (who:getStat(s) >= v) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
            str:add(num>0 and "," or "",c,("%s %d"):format(who.stats_def[s].short_name:capitalize(), v), {"color", "LAST"})
            num = num + 1
         end
      end
      if num>0 then str:add(true) end
   end
   if req.level then
      if who.level < req.level or is_ctrl then
         local c = (who.level >= req.level) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
         str:add(c, mod_align_stat(),("Level %d"):format(req.level), {"color", "LAST"}, true)
      end
   end
   if req.talent then
      for _, tid in ipairs(req.talent) do
         if type(tid) == "table" then
            if who:getTalentLevelRaw(tid[1]) < tid[2] or is_ctrl then
               local c = (who:getTalentLevelRaw(tid[1]) >= tid[2]) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
               str:add(c, num > 0 and mod_align_stat() or "",("%s %d"):format(who:getTalentFromId(tid[1]).name, tid[2]), {"color", "LAST"}, true)
               num = num + 1
            end
         else
            if not who:knowTalent(tid) or is_ctrl then
               local c = who:knowTalent(tid) and {"color", 0x00,0xff,0x00} or {"color", 0xff,0x00,0x00}
               str:add(c, num > 0 and mod_align_stat() or "",("%s"):format(who:getTalentFromId(tid).name), {"color", "LAST"}, true)
               num = num + 1
            end
         end
      end
   end
   local str_out = tstring{}
   if num>0 then
      str_out:add(mod_align_stat("Reqs"))
      str_out:merge( str )
   end
   return str_out
end

return _M