local SayBuffId = 84011
local YellBuffId = 84012
local EmoteBuffId = 84013

function ApplyBuff(player, buffId)
    player:AddAura(buffId, player)
end

function RemoveBuff(player, buffId)
    player:RemoveAura(buffId)
end

function ChatBuffs(event, player, command, message)
    local cmd, arg = string.match(message, "^%.(%w+)%s*(%d*)$")
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

RegisterPlayerEvent(42, ChatBuffs)






