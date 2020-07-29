local AIO = AIO or require("AIO")


if AIO.AddAddon() then
    return
end

local DiceRollerHandlers = AIO.AddHandlers("DiceRollerHandlers", {})



function DiceRollerAddonRoll(mod1, mod2, mod3)
	AIO.Handle("DiceRollerHandlers","DiceRollerAddonRoll", mod1, mod2, mod3)
end

function RaidRollerAddonRoll(mod1, mod2, mod3, mod4, name)
	AIO.Handle("DiceRollerHandlers","RaidRollerAddonRoll", mod1, mod2, mod3, mod4, name)
end