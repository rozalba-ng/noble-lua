--Скрипт определяет дисплей айди персонажа использовавшего трубку и вешает спелл специально написанный для этой модели.
local ITEM_FOR_USE = 600013 --Айди смеси которая будет тратиться при использовании трубки.


--Способности которые используются на персонажа при использовании трубки
local SPELL_FOR_1_GROUP = 84051
local SPELL_FOR_2_GROUP = 84052

---------Дисплей айди----------
local HUMAN_MALE = 49
local HUMAN_FEM = 50

local GNOME_MALE = 6894
local GNOME_FEM = 6895 

local ELF_MALE = 15476 
local ELF_FEM = 15475

local GOBLIN_MALE = 6894
local GOBLIN_FEM = 6895

local DWORF_MALE = 53
local DWORF_FEM = 54

local ORC_MALE = 51
local ORC_FEM = 52

local TROLL_MALE = 1479 
local TROLL_FEM = 1478

local TAUREN_MALE = 59
local TAUREN_FEM = 60

-------------------------------

local function OnPipeUse(event, player, item, target)
	if player:HasItem(ITEM_FOR_USE) then
		local playerDisID = player:GetDisplayId()
		if playerDisID == HUMAN_MALE or playerDisID == ORC_MALE or playerDisID == ORC_FEMALE or playerDisID == DWORF_MALE or playerDisID == TROLL_MALE or playerDisID == ELF_FEM then
			player:RemoveItem(ITEM_FOR_USE,1)
			player:CastSpell(player,SPELL_FOR_2_GROUP)
		else
			player:RemoveItem(ITEM_FOR_USE,1)
			player:CastSpell(player,SPELL_FOR_1_GROUP)
		end
	else
		player:SendNotification("Вам необходима курительная смесь для того, чтобы использовать трубку!")
	end
end



RegisterItemEvent(600041,2,OnPipeUse)