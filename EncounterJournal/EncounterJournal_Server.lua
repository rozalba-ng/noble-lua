------------
--// Created by: Harusha
--// hsmichaeldn@gmail.com
--// Date: *************
------------

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                              AIO Load                                   ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

local AIO = AIO or require("AIO")
local EJ_Handlers = AIO.AddHandlers("EJ_Handlers", {})

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                     Creating SQL structures                             ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

WorldDBQuery([[
CREATE TABLE IF NOT EXISTS `custom_EJ_NewsTable` (
  `idkey` INT(11) NOT NULL AUTO_INCREMENT,
  `idposs` int(11) DEFAULT NULL,
  `tablename` VARCHAR(50) NULL DEFAULT NULL,
  `title` VARCHAR(50) NULL DEFAULT NULL,
  `image` VARCHAR(50) NULL DEFAULT NULL,
  `text1` TEXT NULL,
  `text2` TEXT NULL,
    PRIMARY KEY (`idkey`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=3
;
]])

WorldDBQuery([[
CREATE TABLE IF NOT EXISTS `custom_EJ_StoryTable` (
  `idkey` INT(11) NOT NULL AUTO_INCREMENT,
  `idposs` int(11) DEFAULT NULL,
  `tablename` VARCHAR(50) NULL DEFAULT NULL,
  `title` VARCHAR(50) NULL DEFAULT NULL,
  `image` VARCHAR(50) NULL DEFAULT NULL,
  `text1` TEXT NULL,
  `text2` TEXT NULL,
    PRIMARY KEY (`idkey`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=3
;
]])

WorldDBQuery([[
CREATE TABLE IF NOT EXISTS `custom_EJ_ServerInfoTable` (
  `idkey` INT(11) NOT NULL AUTO_INCREMENT,
  `idposs` int(11) DEFAULT NULL,
  `tablename` VARCHAR(50) NULL DEFAULT NULL,
  `title` VARCHAR(50) NULL DEFAULT NULL,
  `image` VARCHAR(50) NULL DEFAULT NULL,
  `text1` TEXT NULL,
  `text2` TEXT NULL,
    PRIMARY KEY (`idkey`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=3
;
]])

WorldDBQuery([[
CREATE TABLE IF NOT EXISTS `custom_EJ_TechInfoTable` (
  `idkey` INT(11) NOT NULL AUTO_INCREMENT,
  `idposs` int(11) DEFAULT NULL,
  `tablename` VARCHAR(50) NULL DEFAULT NULL,
  `title` VARCHAR(50) NULL DEFAULT NULL,
  `image` VARCHAR(50) NULL DEFAULT NULL,
  `text1` TEXT NULL,
  `text2` TEXT NULL,
    PRIMARY KEY (`idkey`)
)
COLLATE='utf8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=3
;
]])

WorldDBQuery([[
CREATE TABLE IF NOT EXISTS `custom_hash`  (
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `hash` int(11) NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;
]])
local function HashInsert()
	if not WorldDBQuery("SELECT * FROM custom_hash WHERE (`name`='EncounterJournalNewsTable')" ) then
		WorldDBQuery("INSERT INTO `world`.`custom_hash`(`name`, `hash`) VALUES ('EncounterJournalNewsTable', 1)");
	end
	if not WorldDBQuery("SELECT * FROM custom_hash WHERE (`name`='EncounterJournalServerInfo')" ) then
		WorldDBQuery("INSERT INTO `world`.`custom_hash`(`name`, `hash`) VALUES ('EncounterJournalServerInfo', 1)");
	end
	if not WorldDBQuery("SELECT * FROM custom_hash WHERE (`name`='EncounterJournalTechInfo')" ) then
		WorldDBQuery("INSERT INTO `world`.`custom_hash`(`name`, `hash`) VALUES ('EncounterJournalTechInfo', 1)");
	end
	if not WorldDBQuery("SELECT * FROM custom_hash WHERE (`name`='Roleplay_Centers')" ) then
		WorldDBQuery("INSERT INTO `world`.`custom_hash`(`name`, `hash`) VALUES ('Roleplay_Centers', 1)");
	end
	if not WorldDBQuery("SELECT * FROM custom_hash WHERE (`name`='ForceOpen')" ) then
		WorldDBQuery("INSERT INTO `world`.`custom_hash`(`name`, `hash`) VALUES ('ForceOpen', 1)");
	end
end
HashInsert()
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                              Variables                                  ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
local C_EncounterJournal = {}
C_EncounterJournal.CheckSum = {}
C_EncounterJournal.VersionVar = 1

function C_EncounterJournal.Colorize(text)
	return tostring("|cff82c5ff[Журнал приключений]: |r" .. text)
end

function table:pack(...)
	return {n = select("#", ...), ...}
end

function detectNil(...)
local arg = table.pack(...)
	for i = 1, arg.n do
		if arg[i] == nil then
			C_EncounterJournal.Colorize("Ошибка структуры данных.")
			return false
		end
	end
return true
end

function C_EncounterJournal:Validate(...)
if player:GetGMRank() < 2 then return false end
	detectNil(...)
end

--local Sql_pattern = [[ \' ]]
local function Sql_v(text)
	return text:gsub("'", "")
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                         Server EJ Cash                                  ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

function C_EncounterJournal:GenerateCheckSum() --// Creating curent CheckSum from SQL
    self.CheckSum["EncounterJournalNewsTable"] = WorldDBQuery("SELECT * FROM custom_hash WHERE (`name`='EncounterJournalNewsTable')" ):GetInt32(1) or 0;
    self.CheckSum["EncounterJournalServerInfo"] = WorldDBQuery("SELECT * FROM custom_hash WHERE (`name`='EncounterJournalServerInfo')" ):GetInt32(1) or 0;
    self.CheckSum["EncounterJournalTechInfo"] = WorldDBQuery("SELECT * FROM custom_hash WHERE (`name`='EncounterJournalTechInfo')" ):GetInt32(1) or 0;
    self.CheckSum["Roleplay_Centers"] = WorldDBQuery("SELECT * FROM custom_hash WHERE (`name`='Roleplay_Centers')" ):GetInt32(1) or 0;
	self.CheckSum["ForceOpen"] = WorldDBQuery("SELECT * FROM custom_hash WHERE (`name`='ForceOpen')" ):GetInt32(1) or 0;
end
C_EncounterJournal:GenerateCheckSum()

function EJ_Handlers.GetEJTableVersions(player) --// Send curent CheckSum to player
    AIO.Handle(player,"EJ_Handlers","SendEJTableVersionsToPlayer",C_EncounterJournal.CheckSum)
end


function C_EncounterJournal:UpdateCheckSum(state) --// Updating CheckSum table SQL
	if state == 1 then
		self.VersionVar = WorldDBQuery("SELECT * FROM custom_hash WHERE (`name`='EncounterJournalNewsTable')" ):GetInt32(1) or 0;
		WorldDBQuery("UPDATE custom_hash SET hash = '" .. self.VersionVar + 1 .. "' WHERE (`name`='EncounterJournalNewsTable')");
	elseif state == 2 then
		self.VersionVar = WorldDBQuery("SELECT * FROM custom_hash WHERE (`name`='EncounterJournalServerInfo')" ):GetInt32(1) or 0;
		WorldDBQuery("UPDATE custom_hash SET hash = '" .. self.VersionVar + 1 .. "' WHERE (`name`='EncounterJournalServerInfo')");
	elseif state == 3 then
		self.VersionVar = WorldDBQuery("SELECT * FROM custom_hash WHERE (`name`='EncounterJournalTechInfo')" ):GetInt32(1) or 0;
		WorldDBQuery("UPDATE custom_hash SET hash = '" .. self.VersionVar + 1 .. "' WHERE (`name`='EncounterJournalTechInfo')");
	elseif state == 4 then
		self.VersionVar = WorldDBQuery("SELECT * FROM custom_hash WHERE (`name`='Roleplay_Centers')" ):GetInt32(1) or 0;
		WorldDBQuery("UPDATE custom_hash SET hash = '" .. self.VersionVar + 1 .. "' WHERE (`name`='Roleplay_Centers')");
	elseif state == 5 then
		self.VersionVar = WorldDBQuery("SELECT * FROM custom_hash WHERE (`name`='ForceOpen')" ):GetInt32(1) or 0;
		WorldDBQuery("UPDATE custom_hash SET hash = '" .. self.VersionVar + 1 .. "' WHERE (`name`='ForceOpen')");
	end
self:GenerateCheckSum()
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                          News Generation                                ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
C_EncounterJournal.NewsTable = {}

function C_EncounterJournal:GenerateNewsFromSQL() --// Создает актуальную таблицу новостей из SQL
self.NewsTable = {}
	local FirstNews = WorldDBQuery("SELECT * FROM custom_EJ_NewsTable WHERE (`idposs`='1')")
	if FirstNews then
		self.NewsTable[1] = {
			["texture"] = FirstNews:GetString(4),
			["text"] = FirstNews:GetString(5),
		}
	end
	
	local SecondNews = WorldDBQuery("SELECT * FROM custom_EJ_NewsTable WHERE (`idposs`='2')")
	if SecondNews then
		self.NewsTable[2] = {
			["text"] = SecondNews:GetString(5),
		}
	end

end
C_EncounterJournal:GenerateNewsFromSQL()


function EJ_Handlers.UpdateNews(player, NewsID, Icon, title, text) --// Обновляет графы новостей на сервере через клиент ГМа
	if player:GetGMRank() < 2 then return end
	if not NewsID or not tonumber(NewsID) or NewsID > 2 or NewsID < 1 then return end
	if not Icon or not title or not text then return end
	
	Icon = Sql_v(Icon)
	title = Sql_v(title)
	text = Sql_v(text)
	
	local EJ_NewsUpdate = WorldDBQuery("SELECT * FROM custom_EJ_NewsTable WHERE (`idposs`='".. NewsID .."')" );
	if(EJ_NewsUpdate ~= nil) then
        WorldDBQuery("UPDATE custom_EJ_NewsTable SET idposs = '" .. NewsID .. "', image = '" .. Icon .. "', title = '" .. title .. "', text1 = '" .. text .. "' WHERE (`idposs`='".. NewsID .."')");
    else
        WorldDBQuery("INSERT INTO `custom_EJ_NewsTable` (`idposs`, `tablename`, `title`, `image`, `text1`) VALUES ('".. NewsID .."', 'News', '".. title .."', '" .. Icon .. "', '" .. text .."')");
    end
	C_EncounterJournal:UpdateCheckSum(1)
	C_EncounterJournal:GenerateNewsFromSQL()
	AIO.Handle(player,"EJ_Handlers","UpdateNewsEJCashClient",C_EncounterJournal.NewsTable, C_EncounterJournal.CheckSum["EncounterJournalNewsTable"])
	player:SendBroadcastMessage(C_EncounterJournal.Colorize("Новости обновлены."))
end


--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                          Polygon Generation                             ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
C_EncounterJournal.PolygonTable = {}

function C_EncounterJournal:GeneratePolygonFromSQL() --// Создает актуальную таблицу сюжетов из SQL
	self.PolygonTable = {}
	
	local PolygonEJCash = WorldDBQuery("SELECT * FROM custom_EJ_StoryTable")
	if PolygonEJCash then
		for i = 1, PolygonEJCash:GetRowCount() do
			self.PolygonTable[i] = {
                ["title"] = PolygonEJCash:GetString(3),
                ["image"] = PolygonEJCash:GetString(4) or "ui-ej-dungeonbutton-kultiras",
                ["texts"] = {
                    PolygonEJCash:GetString(5) or " ",
                    PolygonEJCash:GetString(6) or " ",
                }
            }
			PolygonEJCash:NextRow()
		end
	end
end
C_EncounterJournal:GeneratePolygonFromSQL()

function C_EncounterJournal:UpdateStoryCash()
	self:UpdateCheckSum(4)
	self:GeneratePolygonFromSQL()
	AIO.Handle(player,"EJ_Handlers","UpdatePolygonEJCashClient",self.PolygonTable, self.CheckSum["Roleplay_Centers"])
	player:SendBroadcastMessage(self.Colorize("Обновление информации успешно завершено."))
end

function EJ_Handlers.DeleteStory(player, PolygonName)
    if player:GetGMRank() < 2 or not PolygonName then return end
	
	PolygonName = Sql_v(PolygonName)

	WorldDBQuery("DELETE FROM custom_EJ_StoryTable WHERE (`title`='".. PolygonName .."')")
    C_EncounterJournal:UpdateCheckSum(4)
    C_EncounterJournal:GeneratePolygonFromSQL()
    AIO.Handle(player,"EJ_Handlers","UpdatePolygonEJCashClient",C_EncounterJournal.PolygonTable, C_EncounterJournal.CheckSum["Roleplay_Centers"])
	player:SendBroadcastMessage(C_EncounterJournal.Colorize( "Сюжет [" .. PolygonName .. "] удален с сервера."))
end

function EJ_Handlers.SendStory(player, StoryTable)
	if player:GetGMRank() < 2 then return end
    if StoryTable["title"] then PolygonName = Sql_v(StoryTable["title"]) else return end
    if StoryTable["image"] then PolygonImage = Sql_v(StoryTable["image"]) else PolygonImage = "ui-ej-dungeonbutton-rubysanctum" end
    if StoryTable["texts"][1] then PolygonText1 = Sql_v(StoryTable["texts"][1]) else PolygonText1 = " " end
    if StoryTable["texts"][2] then PolygonText2 = Sql_v(StoryTable["texts"][2]) else PolygonText2 = " " end
    
    
    local SQLNewsCheck = WorldDBQuery("SELECT * FROM custom_EJ_StoryTable WHERE (`title`='".. PolygonName .."')" );
    if(SQLNewsCheck ~= nil) then
        WorldDBQuery("UPDATE custom_EJ_StoryTable SET idposs = '0', image = '" .. PolygonImage .. "', title = '" .. PolygonName .. "', text1 = '" .. PolygonText1 .. "', text2 = '" .. PolygonText2 .. "' WHERE (`title`='".. PolygonName .."')");
    else
        WorldDBQuery("INSERT INTO `custom_EJ_StoryTable` (`idposs`, `tablename`, `title`, `image`, `text1`, `text2`) VALUES ('1', 'Roleplay_Centers', '".. PolygonName .."', '" .. PolygonImage .. "', '" .. PolygonText1 .."', '" .. PolygonText2 .."')");
    end
    C_EncounterJournal:UpdateStoryCash()
end

function EJ_Handlers.UpdateStory(player, StoryName, text, state)
	if player:GetGMRank() < 2 then return end
	if not StoryName or not text then return end
	if state > 2 or state < 1 then return end
	
	StoryName = Sql_v(StoryName)
	text = Sql_v(text)
	
	if state == 1 then
		WorldDBQuery("UPDATE custom_EJ_StoryTable SET text1 = '" .. text .. "' WHERE (`title`='".. StoryName .."')");
	elseif state == 2 then
		WorldDBQuery("UPDATE custom_EJ_StoryTable SET text2 = '" .. text .. "' WHERE (`title`='".. StoryName .."')");
	end
	C_EncounterJournal:UpdateStoryCash()
end


--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                         Server Info Generation                          ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
C_EncounterJournal.ServerInfo = {}

function C_EncounterJournal:GenerateServerInfoFromSQL()
	self.ServerInfo = {}
	
	local ServerInfoEJCash = WorldDBQuery("SELECT * FROM custom_EJ_ServerInfoTable")
	if ServerInfoEJCash then
		for i = 1, ServerInfoEJCash:GetRowCount() do
			self.ServerInfo[i] = {
				["title"] = ServerInfoEJCash:GetString(3) or "Error",
				["texture"] = ServerInfoEJCash:GetString(4) or "inv_misc_questionmark",
				["text"] = ServerInfoEJCash:GetString(5) or "Error",
				}
			ServerInfoEJCash:NextRow()
		end
	end
end
C_EncounterJournal:GenerateServerInfoFromSQL()


function C_EncounterJournal:UpdateServerInfoCash()
	self:UpdateCheckSum(2)
	self:GenerateServerInfoFromSQL()
	AIO.Handle(player,"EJ_Handlers","UpdateServerListButtonEJCashClient",C_EncounterJournal.ServerInfo, C_EncounterJournal.CheckSum["EncounterJournalServerInfo"])
	player:SendBroadcastMessage(self.Colorize("Обновление информации успешно завершено."))
end

function EJ_Handlers.CreateServerButtons(player, title, texture)
    if player:GetGMRank() < 2 then return end
	if title == nil then return end
    if texture == nil then return end
    
	title = Sql_v(title)
	texture = Sql_v(texture)
	
	C_EncounterJournal.ButtonCreatorVar = WorldDBQuery("SELECT * FROM custom_EJ_ServerInfoTable WHERE (`title`='" .. title .. "')" );
    if(C_EncounterJournal.ButtonCreatorVar ~= nil) then
        WorldDBQuery("UPDATE custom_EJ_ServerInfoTable SET idposs = '0', image = '" .. texture .. "', title = '" .. title .. "', text2 = '0' WHERE (`title`='".. title .."')");
    else
        WorldDBQuery("INSERT INTO `custom_EJ_ServerInfoTable` (`idposs`, `tablename`, `title`, `image`, `text1`, `text2`) VALUES ('0', 'Tech', '".. title .."', '" .. texture .. "', 'Текст отсутствует', '0')");
    end
    C_EncounterJournal:UpdateServerInfoCash()
end

function EJ_Handlers.DeleteServerButtons(player, title)
    if player:GetGMRank() < 2 then return end
	if title == nil then return end
    
	title = Sql_v(title)
	
	C_EncounterJournal.ButtonCreatorVar = WorldDBQuery("SELECT * FROM custom_EJ_ServerInfoTable WHERE (`title`='" .. title .. "')" );
    
	if(C_EncounterJournal.ButtonCreatorVar) then
        WorldDBQuery("DELETE FROM custom_EJ_ServerInfoTable WHERE (`title`='".. title .."')")
		C_EncounterJournal:UpdateServerInfoCash()
    end
end

function EJ_Handlers.UpdateServerButtons(player, title, text)
	if player:GetGMRank() < 2 then return end
	if not title or not text then return end
	
	title = Sql_v(title)
	text = Sql_v(text)
	
	C_EncounterJournal.ButtonUpdateVar = WorldDBQuery("SELECT * FROM custom_EJ_ServerInfoTable WHERE (`title`='" .. title .. "')" );
	if(C_EncounterJournal.ButtonUpdateVar ~= nil) then
        WorldDBQuery("UPDATE custom_EJ_ServerInfoTable SET text1 = '" .. text .. "' WHERE (`title`='".. title .."')");
		C_EncounterJournal:UpdateServerInfoCash()
    end
end
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                            Replace (switch) Funcs                       ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
C_EncounterJournal.ReplaceStorage = {
[1] = {
	function() return C_EncounterJournal.PolygonTable end,
	function() C_EncounterJournal:UpdateStoryCash() end,
	"custom_EJ_StoryTable",
},
[2] = {
	function() return C_EncounterJournal.ServerInfo end,
	function() C_EncounterJournal:UpdateServerInfoCash() end,
	"custom_EJ_ServerInfoTable",
},
[3] = {
	function() return C_EncounterJournal.TechInfo end,
	function() C_EncounterJournal:UpdateTechInfoCash() end,
	"custom_EJ_TechInfoTable",
},
}

function EJ_Handlers.ReplaceDown(player, objectName, state)
	if player:GetGMRank() < 2 then return end
	if not objectName then return end
	if not C_EncounterJournal.ReplaceStorage[state] then return end
	
	objectName = Sql_v(objectName)
	
	local ReplaceCash = {}
	ReplaceCash.IDkey = nil
	
	for k, v in pairs(C_EncounterJournal.ReplaceStorage[state][1]()) do
		if v["title"] == tostring(objectName) then
			ReplaceCash.IDkey = k
		end
	end
	
	if ReplaceCash.IDkey then
		if ReplaceCash.IDkey < #C_EncounterJournal.ReplaceStorage[state][1]() then
			ReplaceCash.First = WorldDBQuery("SELECT * FROM " .. C_EncounterJournal.ReplaceStorage[state][3] .. " WHERE (`title`='".. objectName .."')" );
			ReplaceCash.Second = WorldDBQuery("SELECT * FROM " .. C_EncounterJournal.ReplaceStorage[state][3] .. " WHERE (`title`='".. C_EncounterJournal.ReplaceStorage[state][1]()[ReplaceCash.IDkey+1]["title"] .."')" );
				if ReplaceCash.First and ReplaceCash.Second then
					WorldDBQuery("UPDATE " .. C_EncounterJournal.ReplaceStorage[state][3] .. " SET image = '" .. ReplaceCash.Second:GetString(4) .. "', title = '" .. ReplaceCash.Second:GetString(3) .. "', text1 = '" .. ReplaceCash.Second:GetString(5) .. "', text2 = '" .. ReplaceCash.Second:GetString(6) .. "' WHERE (`idkey`='".. ReplaceCash.First:GetInt32(0) .."')");
					WorldDBQuery("UPDATE " .. C_EncounterJournal.ReplaceStorage[state][3] .. " SET image = '" .. ReplaceCash.First:GetString(4) .. "', title = '" .. ReplaceCash.First:GetString(3) .. "', text1 = '" .. ReplaceCash.First:GetString(5) .. "', text2 = '" .. ReplaceCash.First:GetString(6) .. "' WHERE (`idkey`='".. ReplaceCash.Second:GetInt32(0) .."')");
					C_EncounterJournal.ReplaceStorage[state][2]()
				end
		end
	end
end

function EJ_Handlers.ReplaceUp(player, objectName, state)
	if player:GetGMRank() < 2 then return end
	if not objectName then return end
	if not C_EncounterJournal.ReplaceStorage[state] then return end
	
	objectName = Sql_v(objectName)
	
	local ReplaceCash = {}
	ReplaceCash.IDkey = nil
	
	for k, v in pairs(C_EncounterJournal.ReplaceStorage[state][1]()) do
		if v["title"] == tostring(objectName) then
			ReplaceCash.IDkey = k
		end
	end
	if ReplaceCash.IDkey then
		if ReplaceCash.IDkey > 1 then
			ReplaceCash.First = WorldDBQuery("SELECT * FROM " .. C_EncounterJournal.ReplaceStorage[state][3] .. " WHERE (`title`='".. objectName .."')" );
			ReplaceCash.Second = WorldDBQuery("SELECT * FROM " .. C_EncounterJournal.ReplaceStorage[state][3] .. " WHERE (`title`='".. C_EncounterJournal.ReplaceStorage[state][1]()[ReplaceCash.IDkey-1]["title"] .."')" );
				if ReplaceCash.First and ReplaceCash.Second then
					WorldDBQuery("UPDATE " .. C_EncounterJournal.ReplaceStorage[state][3] .. " SET image = '" .. ReplaceCash.Second:GetString(4) .. "', title = '" .. ReplaceCash.Second:GetString(3) .. "', text1 = '" .. ReplaceCash.Second:GetString(5) .. "', text2 = '" .. ReplaceCash.Second:GetString(6) .. "' WHERE (`idkey`='".. ReplaceCash.First:GetInt32(0) .."')");
					WorldDBQuery("UPDATE " .. C_EncounterJournal.ReplaceStorage[state][3] .. " SET image = '" .. ReplaceCash.First:GetString(4) .. "', title = '" .. ReplaceCash.First:GetString(3) .. "', text1 = '" .. ReplaceCash.First:GetString(5) .. "', text2 = '" .. ReplaceCash.First:GetString(6) .. "' WHERE (`idkey`='".. ReplaceCash.Second:GetInt32(0) .."')");
					C_EncounterJournal.ReplaceStorage[state][2]()
				end
		end
	end
end
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                           Tech Info Generation                          ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
C_EncounterJournal.TechInfo = {}

function C_EncounterJournal:GenerateTechInfoFromSQL() --// Создает актуальную таблицу информации о функионале из SQL
	self.TechInfo = {}
	
	local TechInfoEJCash = WorldDBQuery("SELECT * FROM custom_EJ_TechInfoTable")
	if TechInfoEJCash then
		for i = 1, TechInfoEJCash:GetRowCount() do
			self.TechInfo[i] = {
				["title"] = TechInfoEJCash:GetString(3) or "Error",
				["texture"] = TechInfoEJCash:GetString(4) or "inv_misc_questionmark",
				["text"] = TechInfoEJCash:GetString(5) or "Error",
				}
			TechInfoEJCash:NextRow()
		end
	end
end
C_EncounterJournal:GenerateTechInfoFromSQL()

function C_EncounterJournal:UpdateTechInfoCash()
	self:UpdateCheckSum(3)
	self:GenerateTechInfoFromSQL()
	AIO.Handle(player,"EJ_Handlers","UpdateTechListButtonEJCashClient",C_EncounterJournal.TechInfo, C_EncounterJournal.CheckSum["EncounterJournalTechInfo"])
	player:SendBroadcastMessage(self.Colorize("Обновление информации успешно завершено."))
end

function EJ_Handlers.CreateTechButtons(player, title, texture)
    if player:GetGMRank() < 2 then return end
	if title == nil then return end
    if texture == nil then return end
    
	title = Sql_v(title)
	texture = Sql_v(texture)
	
	C_EncounterJournal.ButtonCreatorVar = WorldDBQuery("SELECT * FROM custom_EJ_TechInfoTable WHERE (`title`='" .. title .. "')" );
    if(C_EncounterJournal.ButtonCreatorVar ~= nil) then
        WorldDBQuery("UPDATE custom_EJ_TechInfoTable SET idposs = '0', image = '" .. texture .. "', title = '" .. title .. "', text2 = '0' WHERE (`title`='".. title .."')");
    else
        WorldDBQuery("INSERT INTO `custom_EJ_TechInfoTable` (`idposs`, `tablename`, `title`, `image`, `text1`, `text2`) VALUES ('0', 'Tech', '".. title .."', '" .. texture .. "', 'Текст отсутствует', '0')");
    end
    C_EncounterJournal:UpdateTechInfoCash()
end

function EJ_Handlers.DeleteTechButtons(player, title)
    if player:GetGMRank() < 2 then return end
	if title == nil then return end
    
	title = Sql_v(title)
	
	C_EncounterJournal.ButtonCreatorVar = WorldDBQuery("SELECT * FROM custom_EJ_TechInfoTable WHERE (`title`='" .. title .. "')" );
    
	if(C_EncounterJournal.ButtonCreatorVar) then
        WorldDBQuery("DELETE FROM custom_EJ_TechInfoTable WHERE (`title`='".. title .."')")
		C_EncounterJournal:UpdateTechInfoCash()
    end
end

function EJ_Handlers.UpdateTechButtons(player, title, text)
	if player:GetGMRank() < 2 then return end
	if not title or not text then return end
	
	title = Sql_v(title)
	text = Sql_v(text)
	
	C_EncounterJournal.ButtonUpdateVar = WorldDBQuery("SELECT * FROM custom_EJ_TechInfoTable WHERE (`title`='" .. title .. "')" );
	if(C_EncounterJournal.ButtonUpdateVar ~= nil) then
        WorldDBQuery("UPDATE custom_EJ_TechInfoTable SET text1 = '" .. text .. "' WHERE (`title`='".. title .."')");
		C_EncounterJournal:UpdateTechInfoCash()
    end
end
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                  	           Force Open  	   	                         ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
function EJ_Handlers.UpdateForceOpenFromClient(player)
	if player:GetGMRank() < 2 then return end
	C_EncounterJournal:UpdateCheckSum(5)
	player:SendBroadcastMessage(C_EncounterJournal.Colorize("Журнал приключений будет открыт при следующем входе в игру."))
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                         Login Cash Update                               ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
function EJ_Handlers.GetUpdateEJTable(player, state)
    if state == 1 then
        AIO.Handle(player,"EJ_Handlers","UpdateNewsEJCashClient",C_EncounterJournal.NewsTable, C_EncounterJournal.CheckSum["EncounterJournalNewsTable"])
    elseif state == 2 then
        AIO.Handle(player,"EJ_Handlers","UpdateServerListButtonEJCashClient",C_EncounterJournal.ServerInfo, C_EncounterJournal.CheckSum["EncounterJournalServerInfo"])
    elseif state == 3 then
        AIO.Handle(player,"EJ_Handlers","UpdateTechListButtonEJCashClient",C_EncounterJournal.TechInfo, C_EncounterJournal.CheckSum["EncounterJournalTechInfo"])
    elseif state == 4 then
        AIO.Handle(player,"EJ_Handlers","UpdatePolygonEJCashClient",C_EncounterJournal.PolygonTable, C_EncounterJournal.CheckSum["Roleplay_Centers"])
    end
end

function C_EncounterJournal.PlayerLogin(event, player, arg2, arg3, arg4)
    AIO.Handle(player,"EJ_Handlers","SendEJTableVersionsToPlayer",C_EncounterJournal.CheckSum)
end
RegisterPlayerEvent(3, C_EncounterJournal.PlayerLogin)

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                        Update All Tables                                ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
function EJ_Handlers.UpdateAll(player)
	if not player:GetLuaCooldown(3) or player:GetGMRank() > 1 then
		player:SetLuaCooldown(3, 3)
		AIO.Handle(player,"EJ_Handlers","UpdateNewsEJCashClient",C_EncounterJournal.NewsTable, C_EncounterJournal.CheckSum["EncounterJournalNewsTable"])
		AIO.Handle(player,"EJ_Handlers","UpdateServerListButtonEJCashClient",C_EncounterJournal.ServerInfo, C_EncounterJournal.CheckSum["EncounterJournalServerInfo"])
		AIO.Handle(player,"EJ_Handlers","UpdateTechListButtonEJCashClient",C_EncounterJournal.TechInfo, C_EncounterJournal.CheckSum["EncounterJournalTechInfo"])
		AIO.Handle(player,"EJ_Handlers","UpdatePolygonEJCashClient",C_EncounterJournal.PolygonTable, C_EncounterJournal.CheckSum["Roleplay_Centers"])
		AIO.Handle(player,"EJ_Handlers","SendEJTableVersionsToPlayer",C_EncounterJournal.CheckSum)
	else
		player:SendBroadcastMessage(C_EncounterJournal.Colorize("Данное действие пока недоступно. Попробуйте позже."))
	end
end


--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                                Debug                                    ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
function C_EncounterJournal.Debug(event, player, command)
	if player:GetGMRank() < 2 then return end
	if ( command == "ej_debughash") then
		C_EncounterJournal:UpdateCheckSum(1)
		C_EncounterJournal:UpdateCheckSum(2)
		C_EncounterJournal:UpdateCheckSum(3)
		C_EncounterJournal:UpdateCheckSum(4)
		C_EncounterJournal:UpdateCheckSum(5)
		player:SendBroadcastMessage(C_EncounterJournal.Colorize("Обновление успешно."))
	end
end
RegisterPlayerEvent(42, C_EncounterJournal.Debug)