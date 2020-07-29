function OnMoneyDetected(event, player, amount)
    if amount > 4000 or amount < -4000 then 
        WorldDBQuery("INSERT INTO `world`.`check_money` (`character_guid`, `amount`,`playerName`,`totalMoney`,`account`) VALUES ('"..player:GetGUIDLow() .."', '".. amount .."','"..player:GetName().."',"..player:GetCoinage()..",'"..player:GetAccountName().."')")
    end
end
RegisterPlayerEvent(14, OnMoneyDetected)