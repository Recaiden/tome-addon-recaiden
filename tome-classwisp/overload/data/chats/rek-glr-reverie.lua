local src = version

local chat = {
	id = "welcome",
}

local funcs = {}
local function regenerateChat()
	chat.answers = {}
	chat.text = string.format("Refresh which talent? (%d refresh%s remaining)",state.remaining,state.remaining == 1 and "" or "es")

	local countTalents = 0

	for tid, _ in pairs(src.talents_cd) do
		local t = src:getTalentFromId(tid)
		if t and not t.is_inscription and not t.generic and not t.uber and not (t.mode and t.mode == "passive") and not t.fixed_cooldown and src.talents_cd[tid] ~= 0 and tid ~= src.T_RELENTLESS_PURSUIT then
			countTalents = countTalents+1
		end
	end

	for tid, _ in pairs(src.talents_cd) do
		local t = src:getTalentFromId(tid)
		if t and not t.is_inscription and not t.generic and not t.uber and not (t.mode and t.mode == "passive") and not t.fixed_cooldown and src.talents_cd[tid] ~= 0 and tid ~= src.T_RELENTLESS_PURSUIT then
			chat.answers[#chat.answers+1] = {
				t.name,
				action=function()
					funcs.rechargeTalent(tid)
					if state.remaining <= 0 or countTalents <= 1 then coroutine.resume(co, state.recharged) end
				end,
				jump=state.remaining > 1 and countTalents > 1 and "welcome" or nil
			}
		end
	end

	table.sort(chat.answers,function(a,b) return a[1] < b[1] end)
	chat.answers[#chat.answers+1] = {state.recharged and "[Cancel] (and waste remaining refreshes!)" or "[Cancel]",action=function() coroutine.resume(co, state.recharged) end}
end
local function rechargeTalent(tid)
	src.talents_cd[tid] = 0

	state.recharged = true
	state.remaining = state.remaining-1
	funcs.regenerateChat()
end
funcs.regenerateChat = regenerateChat
funcs.rechargeTalent = rechargeTalent

funcs.regenerateChat()
newChat(chat)
return "welcome"
