local Water = 159
local Bread = 4540
local NoItems = "У вас недостаточно предметов."

local function CommonOnUncommon(player, HowMany)
    local isItem = player:HasItem(Bread, HowMany)
    if isItem then
        -- player:SendBroadcastMessage("Yes")
        player:RemoveItem(Bread, HowMany)
        player:AddItem(Water, HowMany/3)
    else
        player:SendBroadcastMessage(NoItems)
    end
end

local function ComChanger(event, player, command)
    if string.find(command, " ") then
        local _, _, cmd, arg = string.find(command, "(%S+)%s+(.*)")
        if cmd == "comtounc" then
            local HowMany = tonumber(arg) or 1
            CommonOnUncommon(player, HowMany)
        end
    end
end

RegisterPlayerEvent(42, ComChanger)

local function UncommonOnCommon(player, HowMany)
    local isItem = player:HasItem(Water, HowMany)
    if isItem then
        -- player:SendBroadcastMessage("Yes")
        player:RemoveItem(Water, HowMany)
        player:AddItem(Bread, HowMany*3)
    else
        player:SendBroadcastMessage(NoItems)
    end
end

local function UncChanger(event, player, command)
    if string.find(command, " ") then
        local _, _, cmd, arg = string.find(command, "(%S+)%s+(.*)")
        if cmd == "unctocom" then
            local HowMany = tonumber(arg) or 1
            UncommonOnCommon(player, HowMany)
        end
    end
end

RegisterPlayerEvent(42, UncChanger)




