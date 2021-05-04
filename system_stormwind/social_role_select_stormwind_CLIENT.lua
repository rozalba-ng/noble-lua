local AIO = AIO or require("AIO")

if AIO.AddAddon() then
    return
end

local  MyHandlers = AIO.AddHandlers("SocialClassSelection", {})

function MyHandlers.Storm_ShowMenu()
	StromwindSystem:Show()
end

function Strom_SelectClass(ind)
  AIO.Handle("SocialClassSelection","SelectClass", ind)
end