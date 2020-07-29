local ITEM_EVENT_ON_USE = 2;

local function itemOnUse(event, player, item, target)
	local accountId = player:GetAccountId();
    if (accountId == 3) then
        local text = "Моя милая Сашенька, я очень старался, чтобы исполнить твоё желание и создать какой-нибудь миленький предметик для тебя ^^. Надеюсь, что у меня неплохо вышло? Ты нашла его сама, да. А теперь, каждый раз открывая и смотря его, читая это, вспоминай и знай, как я сильно тебя люблю. Ты лучшая.  Твой Андрей.";
        player:SendAddonMessage("VALENTINE_INJECT", text, 7, player);
	PrintError(player:GetName().." SEND");
    else
	PrintError(player:GetName().." WRONG ACCOUNT");
    end
end


RegisterItemEvent(300025, ITEM_EVENT_ON_USE, itemOnUse);
