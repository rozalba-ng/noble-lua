local AIO = AIO or require("AIO")

local GoShopHandlers = AIO.AddHandlers("GoShopHandlers", {})
-----------------------------
local ADDON_EVENT_ON_MESSAGE = 30;
local GET_GOB_MODEL_PATHES_QUERY = "SELECT gob_guid, Path, Xpos, Ypos, Zpos, Rotation FROM gob_pathes";
local GET_ITEM_INFO = "SELECT BuyPrice, name,spellid_1 FROM item_template"
local GET_CATEGORIES = "SELECT * FROM gameobject_shop_category"
local ADDON_REPLY_PREFIX = "ELUNA_DRESSUP"
local ADDON_GET_PREFIX = "ELUNA_DRESSUP_GET"

local pathesCash = {}
local modelDataList = {}
local shopCache = {}
local gobCategoryData = {}

local function ReloadGoPreview()
	local gob_pathes_query = WorldDBQuery(GET_GOB_MODEL_PATHES_QUERY)
	for i = 1, gob_pathes_query:GetRowCount() do
		pathesCash[tonumber(gob_pathes_query:GetInt32(0))] = tostring(gob_pathes_query:GetString(1).."@"..gob_pathes_query:GetFloat(2).."@"..gob_pathes_query:GetFloat(3).."@"..gob_pathes_query:GetFloat(4).."@"..gob_pathes_query:GetFloat(5))
		local modelData = {}
		modelData.entry = gob_pathes_query:GetInt32(0)
		modelData.path = gob_pathes_query:GetString(1)
		modelData.x = gob_pathes_query:GetFloat(2)
		modelData.y = gob_pathes_query:GetFloat(3)
		modelData.z = gob_pathes_query:GetFloat(4)
		modelData.rotation = gob_pathes_query:GetFloat(5)
		modelDataList[modelData.entry] = modelData
		gob_pathes_query:NextRow()
	end
	if modelDataList[517958] then
		print(modelDataList[517958].entry, modelDataList[517958].path)
	else
		print("Cannot find 517958.")
	end
	local gob_category_query = WorldDBQuery(GET_CATEGORIES)
	for i = 1, gob_category_query:GetRowCount() do
		local item_entry, _category, _subcategory, _taglist = gob_category_query:GetInt32(0), gob_category_query:GetString(1),gob_category_query:GetString(2),gob_category_query:GetString(3)
		local data = {category = _category, subcategory = _subcategory, taglist = _taglist}
		local q_item_info = WorldDBQuery(GET_ITEM_INFO.." WHERE entry = "..item_entry)
		local item = {}
		item.price = q_item_info:GetInt32(0)
		item.item_entry = item_entry
		item.name = q_item_info:GetString(1)
		item.gob_entry = q_item_info:GetInt32(2)
		item.model_data = modelDataList[item.gob_entry]
		item.category = data
		if item_entry == 517958 then
			print("found 517958")
		end
		if item.model_data then
			table.insert(shopCache,item)
		end
		gob_category_query:NextRow()
		
	end
	
end
ReloadGoPreview()

local function AddonMessageEvent(event, sender, type, prefix, msg, target)
	if(prefix == ADDON_GET_PREFIX and type == 7 and sender == target)then
		if pathesCash[tonumber(msg)] ~= nil then
			gob_path = string.gsub(pathesCash[tonumber(msg)], "\r","", n)
			sender:SendAddonMessage(ADDON_REPLY_PREFIX,gob_path,7,sender)
		end
	end
	
end
local function containsCheck(list, x)
	for _, v in pairs(list) do
		if v.item_entry == x then return v end
	end
	return false
end
function GoShopHandlers.BuyItem(player,entry)
	local info = containsCheck(shopCache,entry)
	if not info then
		player:Print("Запрещено для предмета с номером "..entry)
		return false 
	end
	local cost = info.price
	local hasMoney = player:GetCoinage() or 0
	if cost > hasMoney then
		player:Print("У вас недостаточно монет для покупки данного предмета.")
	else
		local item = player:AddItem(entry,1)
		if not item then
			player:Print("Повторите с свободным местом в инвентаре")
		else
			player:SetCoinage(hasMoney-cost)
		end
	end
end
local function OnPlayerCommand(event, player,command)
	if(string.match(command,'reloadgopreview')) then
		if player:GetGMRank() > 1 then
			player:SendBroadcastMessage("Перезагрузка предпросмотра GO...")
			ReloadGoPreview()
			player:SendBroadcastMessage("Успешна")
		end
	end
end
local function OnLogin(event, player)
	AIO.Handle(player,"GoShopHandlers","SendShop",shopCache)
end
RegisterPlayerEvent(3, OnLogin)
RegisterPlayerEvent(42, OnPlayerCommand)
RegisterServerEvent(ADDON_EVENT_ON_MESSAGE, AddonMessageEvent);