MultiBot.raidus = MultiBot.newFrame(MultiBot, -340, -126, 32, 884, 884)
MultiBot.raidus.addTexture("Interface\\AddOns\\MultiBot\\Textures\\Raidus.blp")
MultiBot.raidus:SetMovable(true)
MultiBot.raidus:Hide()

MultiBot.raidus.raid = {}
MultiBot.raidus.raid.members = {}
MultiBot.raidus.raid.numbers = {}
MultiBot.raidus.raid.targets = {}

MultiBot.raidus.addFrame("Pool", -20, 360, 28, 160, 490)
MultiBot.raidus.addFrame("Btop", -35, 822, 24, 128, 32).addTexture("Interface\\AddOns\\MultiBot\\Textures\\Raidus_Banner_Top.blp")
MultiBot.raidus.addFrame("Bbot", -35, 354, 24, 128, 32).addTexture("Interface\\AddOns\\MultiBot\\Textures\\Raidus_Banner_Bottom.blp")
MultiBot.raidus.addFrame("Group8", -185, 364, 28, 160, 240)
MultiBot.raidus.addFrame("Group7", -350, 364, 28, 160, 240)
MultiBot.raidus.addFrame("Group6", -515, 364, 28, 160, 240)
MultiBot.raidus.addFrame("Group5", -680, 364, 28, 160, 240)
MultiBot.raidus.addFrame("Group4", -185, 604, 28, 160, 240)
MultiBot.raidus.addFrame("Group3", -350, 604, 28, 160, 240)
MultiBot.raidus.addFrame("Group2", -515, 604, 28, 160, 240)
MultiBot.raidus.addFrame("Group1", -680, 604, 28, 160, 240)
MultiBot.raidus.from = 1
MultiBot.raidus.to = 11

MultiBot.raidus.movButton("Move", -780, 790, 90, MultiBot.tips.move.raidus)

MultiBot.raidus.wowButton("x", -13, 841, 16, 20, 12)
.doLeft = function(pButton)
	local tButton = MultiBot.frames["MultiBar"].frames["Main"].buttons["Raidus"]
	tButton.doLeft(tButton)
end

MultiBot.raidus.wowButton("Load", -762, 360, 80, 20, 12)
.doLeft = function(pButton)
	local tPool = MultiBot.raidus.frames["Pool"]
	local tLoad = MultiBot.doSplit(MultiBotSave["Raidus"], ";")
	
	for i = 1, 8, 1 do
		local tGroup = MultiBot.doSplit(tLoad[i], ",")
		
		for j = 1, 5, 1 do
			local tDrop = MultiBot.raidus.frames["Group" .. i].frames["Slot" .. j]
			local tName = tGroup[j]
			
			if(tName ~= "-") then
				for tIndex, tDrag in pairs(tPool.frames) do
					if(tDrag.name ~= nil and tDrag.name == tName) then
						local tVisible = tDrag:IsVisible()
						local tParent = tDrag.parent
						local tHeight = tDrag.height
						local tWidth = tDrag.width
						local tSlot = tDrag.slot
						local tX = tDrag.x
						local tY = tDrag.y
						
						MultiBot.raidus.doDrop(tDrag, tDrop.parent, tDrop.x, tDrop.y, tDrop.width, tDrop.height, tDrop.slot)
						if(tDrop:IsVisible()) then tDrag:Show() else tDrag:Hide() end
						
						MultiBot.raidus.doDrop(tDrop, tParent, tX, tY, tWidth, tHeight, tSlot)
						if(tVisible) then tDrop:Show() else tDrop:Hide() end
					end
				end
			end
		end
	end
end

MultiBot.raidus.wowButton("Save", -679, 360, 80, 20, 12)
.doLeft = function(pButton)
	local tSave = ""
	
	for i = 1, 8, 1 do
		local tGroup = ""
		
		for j = 1, 5, 1 do
			local tSlot = MultiBot.raidus.frames["Group" .. i].frames["Slot" .. j]
			local tName = MultiBot.IF(tSlot.name == nil, "-", tSlot.name)
			tGroup = tGroup .. MultiBot.IF(tGroup == "", "", ",")
			tGroup = tGroup .. tName
		end
		
		tSave = tSave .. MultiBot.IF(tSave == "", "", ";")
		tSave = tSave .. tGroup
	end
	
	MultiBotSave["Raidus"] = tSave
	SendChatMessage("I wrote it down.", "SAY")
end



MultiBot.raidus.wowButton("Apply", -597, 360, 80, 20, 12)
.doLeft = function(pButton)
	MultiBot.raidus.getRaidState()
	if(MultiBot.raidus.getRaidTarget()) then return end
	table.wipe(MultiBot.index.raidus)
	
	local tMembers = MultiBot.raidus.raid.members
	local tNumbers = MultiBot.raidus.raid.numbers
	local tTargets = MultiBot.raidus.raid.targets
	
	for tName, tValue in pairs(MultiBot.frames["MultiBar"].frames["Units"].buttons) do
		if(tValue.state) then
			if(tTargets[tName] == nil) then
				if(UnitInGroup(tName) or UnitInRaid(tName)) then UninviteUnit(tName) end
				SendChatMessage(".playerbot bot remove " .. tName, "SAY")
			end
		else
			if(tTargets[tName] ~= nil) then
				table.insert(MultiBot.index.raidus, tName)
			end
		end
	end
	
	if(table.getn(MultiBot.index.raidus) > 0) then
		MultiBot.timer.invite.roster = "raidus"
		MultiBot.timer.invite.needs = table.getn(MultiBot.index.raidus)
		MultiBot.timer.invite.index = 1
		MultiBot.auto.invite = true
		SendChatMessage(MultiBot.info.starting, "SAY")
	else
		MultiBot.raidus.doRaidSort()
	end
end

MultiBot.raidus.wowButton("<", -40, 360, 16, 20, 12)
.doLeft = function(pButton)
	for k,v in pairs(MultiBot.raidus.frames["Pool"].frames) do v:Hide() end
	
	MultiBot.raidus.from = MultiBot.raidus.from - 11
	MultiBot.raidus.to = MultiBot.raidus.to - 11
	
	if(MultiBot.raidus.to < 1) then
		MultiBot.raidus.from = MultiBot.raidus.slots - 10
		MultiBot.raidus.to = MultiBot.raidus.slots
	end
	
	for i = 1, MultiBot.raidus.slots, 1 do
		local tSlot = MultiBot.raidus.frames["Pool"].frames["Slot" .. i]
		if(i >= MultiBot.raidus.from and i <= MultiBot.raidus.to) then tSlot:Show() else tSlot:Hide() end
	end
end

MultiBot.raidus.wowButton(">", -20, 360, 16, 20, 12)
.doLeft = function(pButton)
	MultiBot.raidus.from = MultiBot.raidus.from + 11
	MultiBot.raidus.to = MultiBot.raidus.to + 11
	
	if(MultiBot.raidus.from > MultiBot.raidus.slots) then
		MultiBot.raidus.from = 1
		MultiBot.raidus.to = 11
	end
	
	for i = 1, MultiBot.raidus.slots, 1 do
		local tSlot = MultiBot.raidus.frames["Pool"].frames["Slot" .. i]
		if(i >= MultiBot.raidus.from and i <= MultiBot.raidus.to) then tSlot:Show() else tSlot:Hide() end
	end
end

MultiBot.raidus.getDrop = function()
	for i = 1, 8, 1 do
		local tGroup = MultiBot.raidus.frames["Group" .. i]
		
		if(MouseIsOver(tGroup)) then
			for j = 1, 5, 1 do
				local tSlot = tGroup.frames["Slot" .. j]
				if(MouseIsOver(tSlot)) then return tSlot end
			end
		end
	end
	
	for i = 1, MultiBot.raidus.slots, 1 do
		local tSlot = MultiBot.raidus.frames["Pool"].frames["Slot" .. i]
		if(MouseIsOver(tSlot)) then return tSlot end
	end
	
	return nil
end

-- SETTTER --

MultiBot.raidus.setRaidus = function()
	local tPool = MultiBot.raidus.frames["Pool"]
	local tSlot = 1
	local tY = 426
	
	for k,v in pairs(tPool.frames) do v:Hide() end
	
	local tBots = {}
	local tIndex = 1
	
	for tName, tValue in pairs(MultiBotGlobalSave) do
		local tDetails = MultiBot.doSplit(tValue, ",")
		local tBot = {}
		
		tBot.name = tName
		tBot.race = tDetails[1]
		tBot.gender = tDetails[2]
		tBot.special = tDetails[3]
		tBot.talents = tDetails[4]
		tBot.class = tDetails[5]
		tBot.level = tonumber(tDetails[6])
		tBot.score = tonumber(tDetails[7])
		
		local tClass = MultiBot.toClass(tBot.class)
		
		tBot.sort = tonumber(tBot.level) * 1000
		+ MultiBot.IF(tClass == "DeathKnight", 1100000
		, MultiBot.IF(tClass == "Druid", 1200000
		, MultiBot.IF(tClass == "Hunter", 1300000
		, MultiBot.IF(tClass == "Mage", 1400000
		, MultiBot.IF(tClass == "Paladin", 1500000
		, MultiBot.IF(tClass == "Priest", 1600000
		, MultiBot.IF(tClass == "Rogue", 1700000
		, MultiBot.IF(tClass == "Shaman", 1800000
		, MultiBot.IF(tClass == "Warlock", 1900000
		, MultiBot.IF(tClass == "Warrior", 2000000
		, 1000000)))))))))) + tonumber(tBot.score);
		
		tBots[tIndex] = tBot
		tIndex = tIndex + 1
	end
	
	for tIndex = 1, table.getn(tBots) do
		local tMax = tIndex
		
		for tSearch = tIndex + 1, table.getn(tBots) do
			if(tBots[tMax].sort < tBots[tSearch].sort) then
				tMax = tSearch
			end
		end
		
		tBots[tIndex], tBots[tMax] = tBots[tMax], tBots[tIndex]
	end
	
	for tIndex = 1, table.getn(tBots) do
		local tBot = tBots[tIndex]
		
		local tFrame = tPool.addFrame("Slot" .. tSlot, 0, tY, 28, 160, 36)
		tFrame.addTexture("Interface\\AddOns\\MultiBot\\Textures\\grey.blp")
		tFrame:SetResizable(false)
		tFrame:SetMovable(true)
		tFrame.class = MultiBot.toClass(tBot.class)
		tFrame.slot = "Slot" .. tSlot
		tFrame.name = tBot.name
		tFrame.bot = tBot
		
		local tButton = tFrame.addButton("Icon", -128, 3, "Interface\\AddOns\\MultiBot\\Icons\\class_" .. strlower(tFrame.class) .. ".blp", "")
		
		tButton:SetScript("OnEnter", function(pButton)
			local tBot = pButton.parent.bot
			local tReward = tBot.level .. "." .. MultiBot.IF(tBot.score < 100, "0", MultiBot.IF(tBot.score < 10, "00", "")) .. tBot.score
			pButton.tip = MultiBot.newFrame(pButton, -pButton.size, 160, 28, 256, 512, "TOPRIGHT")
			pButton.tip.addTexture("Interface\\AddOns\\MultiBot\\Textures\\Raidus_Wanted.blp")
			pButton.tip.addModel(tBot.name, 0, 64, 160, 240, 1.0)
			pButton.tip.addText("1", "|cff555555- WANTED -|h", "TOP", 0, -30, 24)
			pButton.tip.addText("2", "|cff555555-DEAD OR ALIVE-|h", "TOP", 0, -55, 24)
			pButton.tip.addText("3", "|cff333333" .. tBot.name .. " - " .. tBot.gender .. " - " .. tBot.race .. "|h", "BOTTOM", 0, 220, 15)
			pButton.tip.addText("4", "|cff333333" .. tBot.class .. " - " .. tBot.talents .. " - " .. tBot.special .. "|h", "BOTTOM", 0, 200, 15)
			pButton.tip.addText("5", "|cff555555--------------------------------------------|h", "BOTTOM", 0, 188, 15)
			pButton.tip.addText("6", "|cff555555CASH - " .. tReward .. " - GOLD|h", "BOTTOM", 0, 170, 20)
			pButton.tip.addText("7", "|cff555555--------------------------------------------|h", "BOTTOM", 0, 160, 15)
			pButton.tip:Show()
		end)
		
		tButton:SetScript("OnMouseDown", function(pButton)
			pButton.parent:StartMoving()
			pButton.parent.isMoving = true
		end)
		
		tButton:SetScript("OnMouseUp", function(pButton)
			pButton.parent:StopMovingOrSizing()
			pButton.parent.isMoving = false
			
			local tDrag = pButton.parent
			local tDrop = MultiBot.raidus.getDrop()
			
			if(tDrop ~= nil) then
				local tParent = tDrag.parent
				local tHeight = tDrag.height
				local tWidth = tDrag.width
				local tSlot = tDrag.slot
				local tX = tDrag.x
				local tY = tDrag.y
				
				MultiBot.raidus.doDrop(tDrag, tDrop.parent, tDrop.x, tDrop.y, tDrop.width, tDrop.height, tDrop.slot)
				MultiBot.raidus.doDrop(tDrop, tParent, tX, tY, tWidth, tHeight, tSlot)
			else
				pButton.parent:ClearAllPoints()
				pButton.parent:SetPoint(pButton.parent.align, pButton.parent.x, pButton.parent.y)
				pButton.parent:SetSize(pButton.parent.width, pButton.parent.height)
			end
		end)
		
		tFrame.addText("1", tBot.level .. " - " .. tBot.class, "BOTTOMLEFT", 36, 18, 12)
		tFrame.addText("2", tBot.score .. " - " .. tBot.special, "BOTTOMLEFT", 36, 6, 12)
		
		if(tSlot > 11) then tFrame:Hide() else tFrame:Show() end
		tSlot = tSlot + 1
		tY = MultiBot.IF(mod(tSlot, 12) == 0, 426, tY - 40)
	end
	
	for i = mod(tSlot, 11), 11, 1 do
		local tFrame = tPool.addFrame("Slot" .. tSlot, 0, tY, 28, 160, 36)
		tFrame.addTexture("Interface\\AddOns\\MultiBot\\Textures\\grey.blp")
		tFrame.slot = "Slot" .. tSlot
		if(tSlot > 11) then tFrame:Hide() else tFrame:Show() end
		tSlot = tSlot + 1
		tY = tY - 40
	end
	
	MultiBot.raidus.slots = tSlot - 1
	
	for i = 1, 8, 1 do
		local tGroup = MultiBot.raidus.frames["Group" .. i]
		local tY = 182
		
		tGroup.addText("Title", "- Group" .. i .. " -", "BOTTOM", 0, 223, 12)
		tGroup.group = "Group" .. i
		
		for j = 1, 5, 1 do
			local tFrame = tGroup.addFrame("Slot" .. j, 0, tY, 28, 160, 36)
			tFrame.addTexture("Interface\\AddOns\\MultiBot\\Textures\\grey.blp")
			tFrame.slot = "Slot" .. j
			tY = tY - 40
		end
	end
end

-- GETTER --

MultiBot.raidus.getRaidState = function()
	table.wipe(MultiBot.raidus.raid.members)
	table.wipe(MultiBot.raidus.raid.numbers)
	
	local tMembers = MultiBot.raidus.raid.members
	local tNumbers = MultiBot.raidus.raid.numbers
	
	local tRaid = GetNumRaidMembers()
	local tGroup = GetNumPartyMembers()
	local tSize = MultiBot.IF(tRaid > tGroup, tRaid, tGroup)
	
	for i = 1, tSize do
		local tName, tRank, tGroup = GetRaidRosterInfo(i)
		if(tName and tRank and tGroup) then
			tMembers[tName] = { index = i, group = tGroup }
			tNumbers[tGroup] = (tNumbers[tGroup] or 0) + 1
		end
	end
end

MultiBot.raidus.getRaidTarget = function()
	table.wipe(MultiBot.raidus.raid.targets)
	
	local tMembers = MultiBot.raidus.raid.members
	local tTargets = MultiBot.raidus.raid.targets
	
	local tSelf = UnitName("player")
	local tUser = true
	local tBots = true
	
	for i = 1, 8 do
		for j = 1, 5 do
			local tName = MultiBot.raidus.frames["Group" .. i].frames["Slot" .. j].name
			if(tName ~= nil) then
				if(tName == tSelf) then tUser = false end
				tTargets[tName] = i
				tBots = false
			end
		end
	end
	
	if(tBots) then SendChatMessage("There is no Bot in the Raid", "SAY") else
	if(tUser) then SendChatMessage("I must be in the Raid!", "SAY") end
	end
	
	return tUser or tBots
end

-- EVENTS --

MultiBot.raidus.doRaidSort = function()
	MultiBot.raidus.getRaidState()
	MultiBot.raidus.getRaidTarget()
	
	local tMembers = MultiBot.raidus.raid.members
	local tNumbers = MultiBot.raidus.raid.numbers
	local tTargets = MultiBot.raidus.raid.targets
	
	for tName, tGroup in pairs(tTargets) do
		if(tMembers[tName] ~= nil and tMembers[tName].group ~= tGroup) then
			if(tNumbers[tGroup]) then
				if(tNumbers[tGroup] or tNumbers[tGroup] < 5) then
					SetRaidSubgroup(tMembers[tName].index, tGroup)
				else
					for xName, xValue in pairs(tMembers) do
						if(xValue.group == tGroup and tTargets[tName] ~= tGroup) then
							SwapRaidSubgroup(tMembers[tName].index, xValue.index)
							MultiBot.raidus.getRaidState()
						end
					end
				end
			else
				SetRaidSubgroup(tMembers[tName].index, tGroup)
			end
		end
	end
	
	SendChatMessage("READY FOR RAID NOW", "SAY")
end

MultiBot.raidus.doDrop = function(pObject, pParent, pX, pY, pWidth, pHeight, pSlot)
	pParent.frames[pSlot] = pObject
	pObject:ClearAllPoints()
	pObject:SetParent(pParent)
	pObject:SetPoint("BOTTOMRIGHT", pX, pY)
	pObject:SetSize(pWidth, pHeight)
	pObject.parent = pParent
	pObject.height = pHeight
	pObject.width = pWidth
	pObject.slot = pSlot
	pObject.x = pX
	pObject.y = pY
end