local NPC_ENTRY = 11013339
local DIALOGUE_TEXT = "Ты хочешь снять баф?"
local DIALOGUE_OPTION_TEXT = "Я больше не эльф."
local CONFIRMATION_TEXT = "Вы уверены?"
local CONFIRMATION_YES_OPTION = "Да"
local CONFIRMATION_NO_OPTION = "Нет"
local BUFF_ID = 100025 
local SEC_BUFF_ID = 100022

local function OnGossipHello(event, player, object)
    player:GossipClearMenu()
    player:GossipSetText(DIALOGUE_TEXT)
    player:GossipMenuAddItem(0, DIALOGUE_OPTION_TEXT, 0, 1)
    player:GossipSendMenu(1, object)
end

local function OnGossipSelect(event, player, object, sender, intid, code)
    if intid == 1 then
        player:GossipClearMenu()
        player:GossipSetText(CONFIRMATION_TEXT)
        player:GossipMenuAddItem(0, CONFIRMATION_YES_OPTION, 0, 2)
        player:GossipMenuAddItem(0, CONFIRMATION_NO_OPTION, 0, 3)
        player:GossipSendMenu(1, object)
    elseif intid == 2 then
        player:RemoveAura(BUFF_ID)
		player:RemoveAura(SEC_BUFF_ID)
        player:GossipComplete()
    elseif intid == 3 then
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NPC_ENTRY, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ENTRY, 2, OnGossipSelect)
