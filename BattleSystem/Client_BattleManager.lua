local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end
---TIMER_CODE FROM wowpedia
local waitTable = {}
local waitFrame = nil
local timerState = false

function BM_wait(delay, func, ...)
  if(type(delay) ~= "number" or type(func) ~= "function") then
    return false
  end
  if not waitFrame then
    waitFrame = CreateFrame("Frame", nil, UIParent)
    waitFrame:SetScript("OnUpdate", function (self, elapse)
	local count = 0
      for i = 1, #waitTable do
        local waitRecord = tremove(waitTable, i)
        local d = tremove(waitRecord, 1)
        local f = tremove(waitRecord, 1)
        local p = tremove(waitRecord, 1)
        if d > elapse then
          tinsert(waitTable, i, {d - elapse, f, p})
          i = i + 1
        else
          count = count - 1
          f(unpack(p))
        end
      end
    end)
  end
  tinsert(waitTable, {delay, func, {...}})
  return true
end

---------------------------------

--Cостояния персонажа
local PState_DEAD = 0
local PState_LIVE = 1
local PState_ESCAPING = 2
---

--Состояния боя
local BState_INVITE = 0
local BState_PREPARING = 1
local BState_STARTED = 2
local BState_PAUSED = 3
local BState_CLOSED = 4
local BState_CANCELED = 5
local BState_ESCAPING = 6 
---

local currentTimer = 0

local BM_Handlers = AIO.AddHandlers("BM_Handlers", {})


local numButtons = 6
local buttonHeight = 25

local dataTable = {}
local playerName = UnitName("player")

local function UnFoc(self)
	self:ClearFocus()

end

local function stateToSting(state)
	return stateList[state]
end

local function update()
  local battleData = dataTable
  FauxScrollFrame_Update(BM_ScrollFrame,#battleData.players,numButtons,buttonHeight)
  local counter = 1

  for index = 1,numButtons do
    local offset = index + FauxScrollFrame_GetOffset(BM_ScrollFrame)
    local button = BM_ScrollFrame.buttons[index]
    button.index = offset
    if offset<=#battleData.players then
		button:SetText("|cffffffff"..battleData.players[offset].name)
		button.num:SetText("|cffffffff"..offset..".")
		if battleData.state == BState_STARTED then
			if battleData.players[offset].flaglist.offline == true then
				button.leftLabel:SetText("|cff56555cОффлайн|r")
			else
				if battleData.players[offset].state == PState_DEAD then
					button.leftLabel:SetText("|cff877472Выбит|r")
					button.centerLabel:SetText("")
					button.rightLabel:SetText("")
					button.icon:Show()
					button.icon:SetTexture("Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8.blp")
				elseif battleData.players[offset].state == PState_LIVE then
					button.leftLabel:SetText("|cff70c255Жив|r")
					button.centerLabel:SetText("")
					button.rightLabel:SetText("|cfffa2720"..battleData.players[offset].hp.."|r ХП.")
					button.icon:Hide()
				end
			end
		elseif battleData.state == BState_PREPARING then
			if offset == 1 then
				button.leftLabel:SetText("")
				button.centerLabel:SetText("Инициатор")
				button.rightLabel:SetText("")
				button.icon:Hide()
			elseif offset == 2 then
				button.leftLabel:SetText("")
				button.centerLabel:SetText("Атакуемый")
				button.rightLabel:SetText("")
				button.icon:Hide()
			elseif battleData.players[offset].startDist < 13.2 then
				button.leftLabel:SetText("")
				button.centerLabel:SetText("Близко")
				button.rightLabel:SetText("")
				button.icon:Hide()
			elseif battleData.players[offset].startDist >= 13.2 and  battleData.players[offset].startDist < 26.4 then
				button.leftLabel:SetText("")
				button.centerLabel:SetText("Недалеко")
				button.rightLabel:SetText("")
				button.icon:Hide()
			elseif battleData.players[offset].startDist >= 26.4 then
				button.leftLabel:SetText("")
				button.centerLabel:SetText("Далеко")
				button.rightLabel:SetText("")
				button.icon:Hide()
			end
		elseif battleData.state == BState_ESCAPING then
			if offset == 1 then
				button.leftLabel:SetText("")
				button.centerLabel:SetText("Убегает")
				button.rightLabel:SetText("")
				button.icon:Hide()
			elseif tContains(battleData.escapeResistors,battleData.players[offset].name) then
				button.leftLabel:SetText("")
				button.centerLabel:SetText("Мешает")
				button.rightLabel:SetText("")
				button.icon:Hide()
			end
		end
		button:Show()
    else
      button:Hide()
    end
  end
end

local BM_MainFrame = CreateFrame("Frame", "BM_MainFrame", UIParent)
BM_MainFrame:SetWidth(250)
BM_MainFrame:SetHeight(270)
BM_MainFrame:SetPoint("CENTER")
BM_MainFrame:Hide()
BM_MainFrame:EnableMouse()
BM_MainFrame:SetMovable(true)
BM_MainFrame:SetBackdrop( { bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", insets={left=4,right=4,top=4,bottom=4}, tileSize=16, tile=true, edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16 } )
BM_MainFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
BM_MainFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
BM_MainFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() self:SetUserPlaced(true) end)
BM_MainFrame:RegisterForDrag("LeftButton","RightButton")
local timerLabel = BM_MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
timerLabel:SetFont("Fonts\\MORPHEUS.TTF", 13, "OUTLINE")
timerLabel:SetPoint("TOP",0,-15)
timerLabel:SetText("Время до конца хода:")




local timer = BM_MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
timer:SetFont("Fonts\\MORPHEUS.TTF", 19, "OUTLINE")
timer:SetPoint("TOP",0,-33)
timer:SetText("[time_in_seconds]")
local youTurnLabel = BM_MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
youTurnLabel:SetFont("Fonts\\MORPHEUS.TTF", 20, "OUTLINE")
youTurnLabel:SetPoint("TOP",0,25)
youTurnLabel:Hide()
youTurnLabel:SetText("Ваш ход")


local btnEscape = CreateFrame("BUTTON", "btnEscape", BM_MainFrame, "UIPanelButtonTemplate");
	btnEscape:SetSize(95, 25)
	btnEscape:SetPoint("BOTTOMRIGHT",-25,15)
	btnEscape:SetText("Побег")
	btnEscape:Hide()
	btnEscape:SetScript("OnClick",
	function(self)
		AIO.Handle("BM_Handlers","TryToEscape")
	end)
	btnEscape:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_LEFT")
    GameTooltip:AddLine("Совершить попытку побега из боя.\nКаждый из участников боя может вам помешать, тем самым\nповысив сложность побега из боя.")
    GameTooltip:Show()
  end)
  btnEscape:SetScript("OnLeave",function(self)
	GameTooltip:Hide()
	end)
	
local btnSkip = CreateFrame("BUTTON", "btnSkip", BM_MainFrame, "UIPanelButtonTemplate");
	btnSkip:SetSize(95, 25)
	btnSkip:SetPoint("BOTTOMLEFT",25,15)
	btnSkip:SetText("Не атаковать")
	btnSkip:Hide()
	btnSkip:SetScript("OnClick",
	function(self)
		AIO.Handle("BM_Handlers","PlayerSkipping")
	end)
	btnSkip:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_LEFT")
    GameTooltip:AddLine("Пропусть свой ход.\nЕсли все игроки пропустят ход, то бой будет завершен.")
    GameTooltip:Show()
  end)
  btnSkip:SetScript("OnLeave",function(self)
	GameTooltip:Hide()
	end)
local btnInterrupt = CreateFrame("BUTTON", "btnInterrupt", BM_MainFrame, "UIPanelButtonTemplate");
	btnInterrupt:SetSize(125, 28)
	btnInterrupt:SetPoint("BOTTOM",0,15)
	btnInterrupt:Hide()
	btnInterrupt:SetText("Помешать побегу")
	btnInterrupt:SetScript("OnClick",
	function(self)
		AIO.Handle("BM_Handlers","InterruptToEscape")
	end)
	btnInterrupt:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_LEFT")
    GameTooltip:AddLine("Каждая помеха повышает сложность побега\nигрока на +1 к порогу броска.")
    GameTooltip:Show()
  end)
  btnInterrupt:SetScript("OnLeave",function(self)
	GameTooltip:Hide()
	end)
	
	
local RollButtonHolder = CreateFrame("Frame", "RollButtonHolder", BM_MainFrame)
RollButtonHolder:SetSize(300, 170.25)
RollButtonHolder:SetPoint("BOTTOM",-40, -108)
	
	RollButtonHolder.RollStr = CreateFrame("Button", "RollButtonHolder.RollStr", RollButtonHolder)  --// First button
	RollButtonHolder.RollStr:SetSize(38,38)
	RollButtonHolder.RollStr:SetPoint("CENTER",-38,0)

	RollButtonHolder.RollStr.Icon = CreateFrame("BUTTON", "RollButtonHolder.RollStr.Icon", RollButtonHolder.RollStr);
	RollButtonHolder.RollStr.Icon:SetNormalTexture("interface\\ICONS\\inv_jewelcrafting_dragonseye05")
	RollButtonHolder.RollStr.Icon:SetHighlightTexture("interface\\ICONS\\inv_jewelcrafting_dragonseye05")
	RollButtonHolder.RollStr.Icon:SetPoint("CENTER",0, 0)
	RollButtonHolder.RollStr.Icon:SetSize(32,32)
	RollButtonHolder.RollStr.Icon:SetAlpha(1)
	RollButtonHolder.RollStr.Icon:SetScript("OnClick", function()
	    AIO.Handle("BM_Handlers","CastRoll",1)
	end)
	RollButtonHolder.RollStr.Icon:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_LEFT")
    GameTooltip:AddLine("Бросить кость судьбы\nСила")
    GameTooltip:Show()
  end)
  RollButtonHolder.RollStr.Icon:SetScript("OnLeave",function(self)
	GameTooltip:Hide()
	end)
  
  
	RollButtonHolder.RollAgila = CreateFrame("Button", "RollButtonHolder.RollAgila", RollButtonHolder)  --// First button
	RollButtonHolder.RollAgila:SetSize(38,38)
	RollButtonHolder.RollAgila:SetPoint("CENTER",0,0)

	RollButtonHolder.RollAgila.Icon = CreateFrame("BUTTON", "RollButtonHolder.RollAgila.Icon", RollButtonHolder.RollAgila);
	RollButtonHolder.RollAgila.Icon:SetNormalTexture("interface\\ICONS\\inv_jewelcrafting_dragonseye03")
	RollButtonHolder.RollAgila.Icon:SetHighlightTexture("interface\\ICONS\\inv_jewelcrafting_dragonseye03")
	RollButtonHolder.RollAgila.Icon:SetPoint("CENTER",0, 0)
	RollButtonHolder.RollAgila.Icon:SetSize(32,32)
	RollButtonHolder.RollAgila.Icon:SetAlpha(1)
	RollButtonHolder.RollAgila.Icon:SetScript("OnClick", function()
	    AIO.Handle("BM_Handlers","CastRoll",2)
	end)
	RollButtonHolder.RollAgila.Icon:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_LEFT")
    GameTooltip:AddLine("Бросить кость судьбы\nЛовкость")
    GameTooltip:Show()
  end)
  RollButtonHolder.RollAgila.Icon:SetScript("OnLeave",function(self)
	GameTooltip:Hide()
	end)
  
	RollButtonHolder.RollInta = CreateFrame("Button", "RollButtonHolder.RollInta", RollButtonHolder)  --// First button
	RollButtonHolder.RollInta:SetSize(38,38)
	RollButtonHolder.RollInta:SetPoint("CENTER",38,0)

	RollButtonHolder.RollInta.Icon = CreateFrame("BUTTON", "RollButtonHolder.RollInta.Icon", RollButtonHolder.RollInta);
	RollButtonHolder.RollInta.Icon:SetNormalTexture("interface\\ICONS\\inv_jewelcrafting_dragonseye04")
	RollButtonHolder.RollInta.Icon:SetHighlightTexture("interface\\ICONS\\inv_jewelcrafting_dragonseye04")
	RollButtonHolder.RollInta.Icon:SetPoint("CENTER",0, 0)
	RollButtonHolder.RollInta.Icon:SetSize(32,32)
	RollButtonHolder.RollInta.Icon:SetAlpha(1)
	RollButtonHolder.RollInta.Icon:SetScript("OnClick", function()
	    AIO.Handle("BM_Handlers","CastRoll",3)
	end)
	RollButtonHolder.RollInta.Icon:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_LEFT")
    GameTooltip:AddLine("Бросить кость судьбы\nИнтеллект")
    GameTooltip:Show()
  end)
   RollButtonHolder.RollInta.Icon:SetScript("OnLeave",function(self)
	GameTooltip:Hide()
	end)
	
	RollButtonHolder.RollHeal = CreateFrame("Button", "RollButtonHolder.RollHeal", RollButtonHolder)  --// First button
	RollButtonHolder.RollHeal:SetSize(38,38)
	RollButtonHolder.RollHeal:SetPoint("CENTER",76,0)

	RollButtonHolder.RollHeal.Icon = CreateFrame("BUTTON", "RollButtonHolder.RollHeal.Icon", RollButtonHolder.RollHeal);
	RollButtonHolder.RollHeal.Icon:SetNormalTexture("interface\\ICONS\\inv_jewelcrafting_dragonseye02")
	RollButtonHolder.RollHeal.Icon:SetHighlightTexture("interface\\ICONS\\inv_jewelcrafting_dragonseye02")
	RollButtonHolder.RollHeal.Icon:SetPoint("CENTER",0, 0)
	RollButtonHolder.RollHeal.Icon:SetSize(32,32)
	RollButtonHolder.RollHeal.Icon:SetAlpha(1)
	RollButtonHolder.RollHeal.Icon:SetScript("OnClick", function()
	    AIO.Handle("BM_Handlers","CastRoll",4)
	end)
	RollButtonHolder.RollHeal.Icon:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_LEFT")
    GameTooltip:AddLine("Бросить кость судьбы\nДух (Лечение)")
    GameTooltip:Show()
  end)
  RollButtonHolder.RollHeal.Icon:SetScript("OnLeave",function(self)
	GameTooltip:Hide()
	end)
	
	RollButtonHolder.Run = CreateFrame("Button", "RollButtonHolder.Run", RollButtonHolder)  --// First button
	RollButtonHolder.Run:SetSize(38,38)
	RollButtonHolder.Run:SetPoint("CENTER",120,0)

	RollButtonHolder.Run.Icon = CreateFrame("BUTTON", "RollButtonHolder.Run.Icon", RollButtonHolder.Run);
	RollButtonHolder.Run.Icon:SetNormalTexture("interface\\ICONS\\ability_karoz_leap")
	RollButtonHolder.Run.Icon:SetHighlightTexture("interface\\ICONS\\ability_karoz_leap")
	RollButtonHolder.Run.Icon:SetPoint("CENTER",0, 0)
	RollButtonHolder.Run.Icon:SetSize(32,32)
	RollButtonHolder.Run.Icon:SetAlpha(1)
	RollButtonHolder.Run.Icon:SetScript("OnClick", function()
	    AIO.Handle("BM_Handlers","StartRunning")
		RollButtonHolder.Run:Hide()
	end)
	RollButtonHolder.Run.Icon:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_LEFT")
    GameTooltip:AddLine("Включить возможность перемещения\nДействует раз в ход 3 секунды.")
    GameTooltip:Show()
  end)
  RollButtonHolder.Run.Icon:SetScript("OnLeave",function(self)
	GameTooltip:Hide()
	end)
	
	
local BM_Frame = CreateFrame("Frame","BM_Frame",BM_MainFrame)
BM_Frame:SetSize(220,numButtons*buttonHeight+16)
BM_Frame:SetPoint("CENTER", 0, -5)
BM_Frame:SetBackdrop( { bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", insets={left=4,right=4,top=4,bottom=4}, tileSize=16, tile=true, edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16 } )
BM_Frame:SetAlpha(0.9)
BM_ScrollFrame = CreateFrame("ScrollFrame","BM_ScrollFrame",BM_Frame,"FauxScrollFrameTemplate")
BM_ScrollFrame:SetPoint("TOPLEFT",0,-8)
BM_ScrollFrame:SetPoint("BOTTOMRIGHT",-30,8)
BM_ScrollFrame:SetScript("OnVerticalScroll",function(self,offset)
  FauxScrollFrame_OnVerticalScroll(self, offset, buttonHeight, update)
end)
BM_ScrollFrame.buttons = {}
for i=1,numButtons do
	BM_ScrollFrame.buttons[i] = CreateFrame("Button",nil,BM_Frame)
	local button = BM_ScrollFrame.buttons[i]
	button:SetSize(166,buttonHeight)

	
	button.rightLabel = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.rightLabel:SetFont("Fonts\\MORPHEUS.TTF", 13, "OUTLINE")
	button.rightLabel:SetPoint("RIGHT",19,0)
	button.rightLabel:SetText("")
	button.num = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.num:SetFont("Fonts\\MORPHEUS.TTF", 13, "OUTLINE")
	button.num:SetPoint("left",-14,0)
	button.num:SetText("")
	button.leftLabel = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.leftLabel:SetFont("Fonts\\MORPHEUS.TTF", 13, "OUTLINE")
	button.leftLabel:SetPoint("RIGHT",-16,0)
	button.leftLabel:SetText("")
	button.centerLabel = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.centerLabel:SetFont("Fonts\\MORPHEUS.TTF", 13, "OUTLINE")
	button.centerLabel:SetPoint("RIGHT",5,0)
	button.centerLabel:SetText("")
	
	button.icon = button:CreateTexture("ARTWORK") 
	button.icon:SetPoint("RIGHT",0,0)
	button.icon:SetWidth(16) 
	button.icon:SetHeight(16)
	
	button:SetNormalFontObject("GameFontHighlightLeft")
	button:SetPoint("TOPLEFT",25,-(i-1)*buttonHeight-8)
	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", function(self)
	if selectedTable == 1 then
		SendChatMessage(".gobput "..FavoriteGos[self.index].id, "WHISPER", nil, playerName);
	elseif selectedTable == 2 then
		SendChatMessage(".npcput "..FavoriteNpcs[self.index].id, "WHISPER", nil, playerName);
	elseif selectedTable == 3 then
		SendChatMessage(".aura add "..FavoriteAuras[self.index].id, "WHISPER", nil, playerName);
	end
  end)
  button:SetScript("OnEnter",function(self)
    GameTooltip:Show()
    
  end)
  button:SetScript("OnLeave",function(self)
    GameTooltip:Hide()
  end)
end



local messageLabelState = { 	[1] = {labelName = "Ролевая отпись нападения", x = 17, y = -25, note = "|cffffffffОтпись будет отправлена в чат /эмоция|r"},
								[2] = {labelName = "ООС мотивация нападения", x = 20, y = -25, note = "|cffffffffУбедитесь, что у вашего персонажа\n достаточно мотива к нападению|r"}}

local targetName = "Name"								
local rpMessage = ""
local oocMessage = ""

local currentState = messageLabelState[1]	

local BattleInitiateFrame = CreateFrame("Frame", "BM_BattleInitiateFrame", UIParent)
BattleInitiateFrame:SetWidth(310)
BattleInitiateFrame:SetHeight(330)
BattleInitiateFrame:Hide()
BattleInitiateFrame:SetPoint("CENTER")
BattleInitiateFrame:SetBackdrop( { bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", insets={left=4,right=4,top=4,bottom=4}, tileSize=16, tile=true, edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16 } )
BattleInitiateFrame:SetBackdrop( { bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", insets={left=4,right=4,top=4,bottom=4}, tileSize=16, tile=true, edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16 } )
	BattleInitiateFrame.topLabel = BattleInitiateFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	BattleInitiateFrame.topLabel:SetFont("Fonts\\MORPHEUS.TTF", 18, "OUTLINE")
	BattleInitiateFrame.topLabel:SetPoint("TOP",0,-15)
	BattleInitiateFrame.topLabel:SetText("Инициация нападения")
	
	BattleInitiateFrame.targetNameLabel = BattleInitiateFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	BattleInitiateFrame.targetNameLabel:SetFont("Fonts\\MORPHEUS.TTF", 15, "OUTLINE")
	BattleInitiateFrame.targetNameLabel:SetPoint("TOP",0,-45)
	BattleInitiateFrame.targetNameLabel:SetText("Цель: "..targetName)


	
	
local messageFrame = CreateFrame('Frame', 'messageFrame', BattleInitiateFrame)
messageFrame:SetWidth(190)
messageFrame:SetHeight(185)
messageFrame:SetPoint("CENTER", BattleInitiateFrame, "CENTER", -40, 25)
messageFrame:EnableMouseWheel(true)

local messageLabel = messageFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
messageLabel:SetFont("Fonts\\MORPHEUS.TTF", 15, "OUTLINE")
local messageLabelnote = BattleInitiateFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
messageLabelnote:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
messageLabelnote:SetPoint("BOTTOM",0,75)

messageLabel:SetPoint("TOP",currentState.x,currentState.y)
messageLabel:SetText(currentState.labelName)
messageLabelnote:SetText(currentState.note)

local messageEditorBackgrund = CreateFrame('Frame', 'messageEditorBackgrund', messageFrame)
messageEditorBackgrund:SetWidth(240)
messageEditorBackgrund:SetHeight(150)
messageEditorBackgrund:EnableMouse(true)
messageEditorBackgrund:SetPoint("CENTER", messageFrame, "CENTER", 40, -25)
messageEditorBackgrund:SetBackdrop(
{
    bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
    edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom	 = 5 }
})
local messageEditorBox = CreateFrame('EditBox', 'messageEditorBox', messageFrame)
messageEditorBox:SetMultiLine(true)
messageEditorBox:SetAutoFocus(false)
messageEditorBox:EnableMouse(true)
messageEditorBox:SetText(rpMessage)
messageEditorBox:SetFont("Fonts\\FRIZQT__.TTF", 13)
messageEditorBox:SetWidth(190)
messageEditorBox:SetHeight(135)
messageEditorBox:EnableMouseWheel(true)
messageEditorBox:SetMaxLetters(400)
messageEditorBox:SetScript("OnEscapePressed", UnFoc);
local messageScrollFrame = CreateFrame('ScrollFrame', 'messageScrollFrame', messageFrame, 'UIPanelScrollFrameTemplate')
messageScrollFrame:SetPoint('TOPLEFT', messageFrame, 'TOPLEFT', 25, -60)
messageScrollFrame:SetPoint('BOTTOMRIGHT', messageFrame, 'BOTTOMRIGHT', 30, 8)
messageScrollFrame:EnableMouseWheel(true)
messageScrollFrame:SetScrollChild(messageEditorBox)

messageEditorBackgrund:SetScript("OnMouseDown", 	function(self)
													messageEditorBox:SetFocus()
													
												end)
	


	
local btnBIMNext = CreateFrame("BUTTON", "btnBIMNext", BattleInitiateFrame, "UIPanelButtonTemplate");
	btnBIMNext:SetSize(80, 25)
	btnBIMNext:SetPoint("BOTTOMRIGHT",-25,15)
	btnBIMNext:SetText("Далее")
	btnBIMNext:SetScript("OnClick",
	function(self)
		rpMessage = messageEditorBox:GetText()
		messageEditorBox:SetText(oocMessage)
		currentState = messageLabelState[2]
		messageLabel:SetPoint("TOP",currentState.x,currentState.y)
		messageLabel:SetText(currentState.labelName)
		messageLabelnote:SetPoint("BOTTOM",0,65)
		messageLabelnote:SetText(currentState.note)
		self:Hide()
		btnBIMSend:Show()
		btnBIMReturn:Show()
	end)
local btnBIMReturn = CreateFrame("BUTTON", "btnBIMReturn", BattleInitiateFrame, "UIPanelButtonTemplate");
	btnBIMReturn:SetSize(80, 25)
	btnBIMReturn:SetPoint("BOTTOMLEFT",25,15)
	btnBIMReturn:SetText("Назад")
	btnBIMReturn:Hide()
	btnBIMReturn:SetScript("OnClick",
	function(self)
		oocMessage = messageEditorBox:GetText()
		messageEditorBox:SetText(rpMessage)
		currentState = messageLabelState[1]
		messageLabel:SetPoint("TOP",currentState.x,currentState.y)
		messageLabel:SetText(currentState.labelName)
		messageLabelnote:SetPoint("BOTTOM",0,75)
		messageLabelnote:SetText(currentState.note)
		btnBIMReturn:Hide()
		btnBIMNext:Show()
		btnBIMSend:Hide()
	end)
local btnBIMSend = CreateFrame("BUTTON", "btnBIMSend", BattleInitiateFrame, "UIPanelButtonTemplate");
	btnBIMSend:SetSize(80, 25)
	btnBIMSend:SetPoint("BOTTOMRIGHT",-25,15)
	btnBIMSend:SetText("Напасть!")
	btnBIMSend:Hide()
	btnBIMSend:SetScript("OnClick",
	function(self)
		oocMessage = messageEditorBox:GetText()
		AIO.Handle("BM_Handlers","SendInitiateData", rpMessage, oocMessage)
		BattleInitiateFrame:Hide()
		oocMessage = ""
		rpMessage = ""
		messageEditorBox:SetText(rpMessage)
		currentState = messageLabelState[1]
		messageLabel:SetPoint("TOP",currentState.x,currentState.y)
		messageLabel:SetText(currentState.labelName)
		messageLabelnote:SetPoint("BOTTOM",0,75)
		messageLabelnote:SetText(currentState.note)
		btnBIMReturn:Hide()
		btnBIMNext:Show()
		btnBIMSend:Hide()
	end)	
local BattleInitiateFrameCloseButton = CreateFrame("BUTTON", "BattleInitiateFrameCloseButton", BattleInitiateFrame,"UIPanelCloseButton")
BattleInitiateFrameCloseButton:SetPoint("TOPRIGHT",8,8)
BattleInitiateFrameCloseButton:SetScript("OnClick",
	function(self)
		BattleInitiateFrame:Hide()
		oocMessage = ""
		rpMessage = ""
		messageEditorBox:SetText(rpMessage)
		currentState = messageLabelState[1]
		messageLabel:SetPoint("TOP",currentState.x,currentState.y)
		messageLabel:SetText(currentState.labelName)
		messageLabelnote:SetPoint("BOTTOM",0,75)
		messageLabelnote:SetText(currentState.note)
		btnBIMReturn:Hide()
		btnBIMNext:Show()
		btnBIMSend:Hide()
	end)

local origin = ChatFrame_OnHyperlinkShow
function ChatFrame_OnHyperlinkShow(frame, link, text, button)
    local type, value = link:match("(%a+):(.+)") 
	if ( type == "EnterBattle" ) then
		AIO.Handle("BM_Handlers","EnterInBattle", tonumber(value))
	else
		 origin(frame, link, text, button)
	end
end

local attackerName = "playerName"
local AcceptionMainFrame = CreateFrame("Frame", "BM_AcceptionMainFrame", UIParent)
AcceptionMainFrame:SetWidth(300)
AcceptionMainFrame:Hide()
AcceptionMainFrame:SetHeight(190)
AcceptionMainFrame:SetPoint("CENTER")
AcceptionMainFrame:SetBackdrop( { bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", insets={left=4,right=4,top=4,bottom=4}, tileSize=16, tile=true, edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16 } )
	AcceptionMainFrame.topLabel = AcceptionMainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	AcceptionMainFrame.topLabel:SetFont("Fonts\\MORPHEUS.TTF", 25, "OUTLINE")
	AcceptionMainFrame.topLabel:SetPoint("TOP",0,-15)
	AcceptionMainFrame.topLabel:SetText("Нападение!")
	
	AcceptionMainFrame.attackerName = AcceptionMainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	AcceptionMainFrame.attackerName:SetText("Вас вызывает на бой "..attackerName)
	AcceptionMainFrame.attackerName:SetFont("Fonts\\MORPHEUS.TTF", 15, "OUTLINE")
	AcceptionMainFrame.attackerName:SetPoint("TOP",0,-40)
	
	AcceptionMainFrame.annotation = AcceptionMainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	AcceptionMainFrame.annotation:SetText("Памятка: |cffffffffВы можете отказаться, если уверены,\n что нападают без причины, либо сдаться\n без боя - будет засчитано ролевое поражение.|r")
	AcceptionMainFrame.annotation:SetFont("Fonts\\MORPHEUS.TTF", 13, "OUTLINE")
	AcceptionMainFrame.annotation:SetPoint("CENTER",0,20)
local AcceptButtonHolder = CreateFrame("Frame", "BM_AcceptButtonHolder", AcceptionMainFrame)
AcceptButtonHolder:SetWidth(250)
AcceptButtonHolder:SetHeight(40)
AcceptButtonHolder:SetPoint("CENTER",0,-20)

	local btnAccept = CreateFrame("BUTTON", "BM_BtnAccept", AcceptButtonHolder, "UIPanelButtonTemplate");
	btnAccept:SetSize(90, 25)
	btnAccept:SetPoint("LEFT",10,0)
	btnAccept:SetText("Согласиться")
	btnAccept:SetScript("OnClick",
	function(self)
		AIO.Handle("BM_Handlers","PlayerAcceptInvite")
		AcceptionMainFrame:Hide()
	end)
	btnAccept:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_LEFT")
    GameTooltip:AddLine("Соглашаясь, вы переходите в фазу подготовки боя, где каждый\nв радиусе 40 сможет присоединиться к битве.")
    GameTooltip:Show()
  end)
  btnAccept:SetScript("OnLeave",function(self)
	GameTooltip:Hide()
	end)
	local btnDecline = CreateFrame("BUTTON", "BM_BtnDecline", AcceptButtonHolder, "UIPanelButtonTemplate");
	btnDecline:SetSize(90, 25)
	btnDecline:SetPoint("RIGHT",-10,0)
	btnDecline:SetText("Отказаться")
	btnDecline:SetScript("OnClick",
	function(self)
		AIO.Handle("BM_Handlers","PlayerDesclineInvite")
		AcceptionMainFrame:Hide()
	end)

	local btnLoose = CreateFrame("BUTTON", "BM_BtnDecline", AcceptButtonHolder, "UIPanelButtonTemplate");
	btnLoose:SetSize(120, 25)
	btnLoose:SetPoint("LEFT",65,-30)
	btnLoose:SetText("Сдаться без боя")
	btnLoose:SetScript("OnClick",
		function(self)
		AIO.Handle("BM_Handlers","PlayerAutolooseInvite")
		AcceptionMainFrame:Hide()
	end)


local LeaveAlertFrame = CreateFrame("Frame", "LeaveAlertFrame", UIParent)
LeaveAlertFrame:SetWidth(400)
LeaveAlertFrame:Hide()
LeaveAlertFrame:SetHeight(185)
LeaveAlertFrame:SetPoint("CENTER",0,300)
LeaveAlertFrame:SetBackdrop( { bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", insets={left=4,right=4,top=4,bottom=4}, tileSize=16, tile=true, edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16 } )
	LeaveAlertFrame.topLabel = LeaveAlertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	LeaveAlertFrame.topLabel:SetFont("Fonts\\MORPHEUS.TTF", 25, "OUTLINE")
	LeaveAlertFrame.topLabel:SetPoint("TOP",0,-15)
	LeaveAlertFrame.topLabel:SetText("Подтверждение")
	
	LeaveAlertFrame.attackerName = LeaveAlertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	LeaveAlertFrame.attackerName:SetText("Выход из боя по неролевой причине")
	LeaveAlertFrame.attackerName:SetFont("Fonts\\MORPHEUS.TTF", 15, "OUTLINE")
	LeaveAlertFrame.attackerName:SetPoint("TOP",0,-40)
	
	LeaveAlertFrame.annotation = LeaveAlertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	LeaveAlertFrame.annotation:SetText("Внимание! |cffffffffВы покидаете бой по неролевой причине\n\nНЕ ИСПОЛЬЗУЙТЕ данную команду, если не уверены,\nчто с функционалом автоматизированного боя\nне возникли технические неполадки.\nВы полностью покините бой без возможности вернуться.|r")
	LeaveAlertFrame.annotation:SetFont("Fonts\\MORPHEUS.TTF", 13, "OUTLINE")
	LeaveAlertFrame.annotation:SetPoint("CENTER",0,-10)
local LeaveAlertFrameButtonHolder = CreateFrame("Frame", "BM_AcceptButtonHolder", LeaveAlertFrame)
LeaveAlertFrameButtonHolder:SetWidth(250)
LeaveAlertFrameButtonHolder:SetHeight(50)
LeaveAlertFrameButtonHolder:SetPoint("BOTTOM",75)

	local btnAccept = CreateFrame("BUTTON", "BM_BtnAccept", LeaveAlertFrameButtonHolder, "UIPanelButtonTemplate");
	btnAccept:SetSize(90, 25)
	btnAccept:SetPoint("LEFT",10,0)
	btnAccept:SetText("Я уверен")
	btnAccept:SetScript("OnClick",
	function(self)
		AIO.Handle("BM_Handlers","TechnicalLeave")
		LeaveAlertFrame:Hide()
	end)
	
	local btnDecline = CreateFrame("BUTTON", "BM_BtnDecline", LeaveAlertFrameButtonHolder, "UIPanelButtonTemplate");
	btnDecline:SetSize(90, 25)
	btnDecline:SetPoint("RIGHT",-10,0)
	btnDecline:SetText("Отмена")
	btnDecline:SetScript("OnClick",
	function(self)
		LeaveAlertFrame:Hide()
		BM_MainFrame:Show()
	end)
		

	
local lastTimestamp = 0	

BM_MainFrame:SetScript("OnUpdate", function (self, elapse)
	if GetTime() - lastTimestamp > 1  and currentTimer > 0 then
		lastTimestamp = GetTime()
		currentTimer = currentTimer - 1
	end
	timer:SetText(currentTimer)
end)
function BM_Handlers.StartBattle(player)
	BM_MainFrame:Show()

end

function BM_Handlers.SetTimer(player,seconds)
	currentTimer = seconds
	lastTimestamp = GetTime()
end

function BM_Handlers.OpenPrepareFrame(player,prepareData)
	BM_MainFrame:Show()

end
function BM_Handlers.EndBattle(player)
	BM_MainFrame:Hide()
end

function BM_Handlers.OpenInitFrame(player,targetName)
	BattleInitiateFrame:Show()
	BattleInitiateFrame.targetNameLabel:SetText("Цель: |cffffffff"..targetName)

end
function BM_Handlers.TechLeaveFrameOpen(player,targetName)
	LeaveAlertFrame:Show()
end
function BM_Handlers.CallToSendTime(player,targetName)

	AIO.Handle("BM_Handlers","SendTime",currentTimer,targetName)
end
function BM_Handlers.OpenInviteFrame(player,attackerName,oocMessage,rpMessage)
	AcceptionMainFrame:Show()
	print("|cffff0000На вас нападает игрок|r "..attackerName.."|cffff0000!\n|cffffcc00Отпись нападения:|r "..rpMessage.."\n|cffffcc00ООС-мотив:|r "..oocMessage)
	AcceptionMainFrame.attackerName:SetText("Вас вызывает на бой |cffffffff"..attackerName)
	--BattleInitiateFrame.targetNameLabel:SetText("Цель: "..targetName)

end

UnitPopupButtons["STARTRPPVP"] = { text = "Ролевое нападение", dist = 0, space = 1 };
table.insert(UnitPopupMenus["RAID_PLAYER"],#UnitPopupMenus["RAID_PLAYER"]-1,"STARTRPPVP")
table.insert(UnitPopupMenus["PARTY"],#UnitPopupMenus["PARTY"]-1,"STARTRPPVP")
table.insert(UnitPopupMenus["PLAYER"],#UnitPopupMenus["PLAYER"]-1,"STARTRPPVP")

hooksecurefunc("UnitPopup_OnClick",function(self)
	local button = self.value;
	if ( button == "STARTRPPVP" ) then
		AIO.Handle("BM_Handlers","StartBattle")
	
	end
 end)

function BM_Handlers.UpdatePlayersFrame(player,battleData)
	dataTable = battleData
	BM_MainFrame:Show()
	btnInterrupt:Hide()
	btnEscape:Hide()
	btnSkip:Hide()
	RollButtonHolder.Run:Hide()
	youTurnLabel:Hide()
	RollButtonHolder:Hide()
	if battleData.state == BState_ESCAPING then
		timerLabel:SetText("Попытка побега!")
	elseif battleData.state == BState_PREPARING then
		timerLabel:SetText("Подготовка к бою:")
		
	elseif battleData.state == BState_STARTED then
		timerLabel:SetText("Время до конца хода:")
	
	end
	if battleData.state == BState_ESCAPING and battleData.players[1].name ~= playerName then
		btnInterrupt:Show()
	end
	if battleData.players[1].name == playerName and battleData.state == BState_STARTED then
		btnEscape:Show()
		youTurnLabel:Show()
		RollButtonHolder:Show()
		RollButtonHolder.Run:Show()
		btnSkip:Show()
	end
	update()
end

	