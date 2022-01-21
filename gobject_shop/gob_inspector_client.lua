GoShop = GoShop or {}
local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

local GoShopHandlers = AIO.AddHandlers("GoShopHandlers", {})


function GoShopHandlers.SendShop(player,shopCache)
	GoShop.SaveShop(shopCache)
end

function GoShop.Buy(entry)
	AIO.Handle("GoShopHandlers","BuyItem", entry)
end
