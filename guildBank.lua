----------- Periodical Guild Bank Box Open (4 boxes per guild)
local function openGuildBankBox()
    CharDBQuery("INSERT INTO `guild_bank_tab` (`guildid`, `TabId`, `TabName`, `TabIcon`, `TabText`) select guildid, 0, '', '', NULL from guild where guildid not in (select guildid from guild_bank_tab where TabId = 0);");
	CharDBQuery("INSERT INTO `guild_bank_tab` (`guildid`, `TabId`, `TabName`, `TabIcon`, `TabText`) select guildid, 1, '', '', NULL from guild where guildid not in (select guildid from guild_bank_tab where TabId = 1);");
	CharDBQuery("INSERT INTO `guild_bank_tab` (`guildid`, `TabId`, `TabName`, `TabIcon`, `TabText`) select guildid, 2, '', '', NULL from guild where guildid not in (select guildid from guild_bank_tab where TabId = 2);");
	CharDBQuery("INSERT INTO `guild_bank_tab` (`guildid`, `TabId`, `TabName`, `TabIcon`, `TabText`) select guildid, 3, '', '', NULL from guild where guildid not in (select guildid from guild_bank_tab where TabId = 3);");
	CharDBQuery("INSERT INTO `guild_bank_tab` (`guildid`, `TabId`, `TabName`, `TabIcon`, `TabText`) select guildid, 4, '', '', NULL from guild where guildid not in (select guildid from guild_bank_tab where TabId = 4);");
	CharDBQuery("INSERT INTO `guild_bank_tab` (`guildid`, `TabId`, `TabName`, `TabIcon`, `TabText`) select guildid, 5, '', '', NULL from guild where guildid not in (select guildid from guild_bank_tab where TabId = 5);");
	CharDBQuery("UPDATE `characters`.`characters` SET `bankSlots`='7' WHERE `bankSlots`<7;");
end

CreateLuaEvent(openGuildBankBox, 100000, 0);