local PLAYER_EVENT_ON_CHAT = 18;
local UNIT_NPC_EMOTESTATE = 83;
local EMOTE_ONESHOT_TALK = 1;

local function blabla(event, player, msg)
    if(msg == "Korova svekla putin molodec")then
        player:SendBroadcastMessage("Test  login!!!");
        player:SetUInt32Value(UNIT_NPC_EMOTESTATE, EMOTE_ONESHOT_TALK);
        --player:EmoteState( 502 );
    end
end;

RegisterPlayerEvent( PLAYER_EVENT_ON_CHAT, blabla )