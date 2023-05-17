local NPC_ID = 11013369
-- НПС Август Риверфол
local GOSSIP_HELLO_TEXT = "Как дела?"
local GOSSIP_FIRSTBTN_TEXT = "Хорошо"
local GOSSIP_SECONDBTN_TEXT = "Плохо"
local GOSSIP_GOODANSWER_TEXT = "Отлично! Рад, что у тебя всё хорошо!"
local GOSSIP_BADANSWER_TEXT = "О, нет! Что случилось?"

local function OnGossipHello(event, player, creature)
    creature:GossipSetText(GOSSIP_HELLO_TEXT)
    creature:GossipMenuAddItem(0, GOSSIP_FIRSTBTN_TEXT, 1, 0)
    creature:GossipMenuAddItem(0, GOSSIP_SECONDBTN_TEXT, 2, 0)
    creature:GossipSendMenu(player)
end

local function OnGossipSelect(event, player, creature, sender, intid, code)
    if intid == 1 then
        creature:SendUnitSay(GOSSIP_GOOD_TEXT, 0)
    elseif intid == 2 then
        creature:SendUnitSay(GOSSIP_BAD_TEXT, 0)
    end
    creature:GossipComplete(player)
end

RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)
