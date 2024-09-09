-- Custom buffs which are not break down.
local SayBuffId = 84127
local YellBuffId = 84128
local EmoteBuffId = 84129

function ApplyBuff(player, buffId)
    player:AddAura(buffId, player)
end

function RemoveBuff(player, buffId)
    player:RemoveAura(buffId)
end

function ChatBuffs(event, player, command, _)
    if string.find(command, " ") then
        local _, _, cmd, arg = string.find(command, "(%S+)%s+(.*)")
		if cmd == "typingsay" then
			if arg == "1" then
				ApplyBuff(player, SayBuffId)
			elseif arg == "0" then
				RemoveBuff(player, SayBuffId)
			else
				player:SendBroadcastMessage("Неверный формат. Попробуйте .typingsay [1/0]")
			end
		elseif cmd == "typingyell" then
			if arg == "1" then
				ApplyBuff(player, YellBuffId)
			elseif arg == "0" then
				RemoveBuff(player, YellBuffId)
			else
				player:SendBroadcastMessage("Неверный формат. Попробуйте .typingyell [1/0]")
			end
		elseif cmd == "typingemote" then
			if arg == "1" then
				ApplyBuff(player, EmoteBuffId)
			elseif arg == "0" then
				RemoveBuff(player, EmoteBuffId)
			else
				player:SendBroadcastMessage("Неверный формат. Попробуйте .typingemote [1/0]")
			end
		end
	end
end

RegisterPlayerEvent(42, ChatBuffs)
