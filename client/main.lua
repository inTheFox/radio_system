--Main.lua
radio = {};
self = radio

radio.state = false;
radio.typing = false;
radio.key = "r";

radio.w = 650*px
radio.h = 550*px
radio.x = (sx - radio.w) / 2
radio.y = (sy - radio.h) / 2

radio.editWeight = 515*px

radio.fonts = {
	["action"] = dxCreateFont("assets/fonts/sbold.ttf", 15*px);
	["editbox"] = dxCreateFont("assets/fonts/regular.ttf", 25*px);
	["header"] = dxCreateFont("assets/fonts/regular.ttf", 25*px);
}

radio.colors = {
	["panel"] = {58,58,58};
	["main_color"] = {255,141,141};
	["item_rectangle"] = {45,45,45};
	["music_process_background"] = {106,106,106};
}

radio.currentMusicData = ""
radio.playedMusicData = {};

radio.traksList = {};
radio.edit = ""
local scroll = 0
local maxItems = 5
local textures = {};

function radioRender()
	dxDrawImage(self.x, self.y,self.w, self.h, "assets/images/panel.png")

	local r,g,b = unpack(self.colors["item_rectangle"]);
	if self.typing then	
		dxDrawRectangle(self.x + 63*px, self.y + 100*px, self.editWeight, 30*px,tocolor(r,g,b,255))
	else
		dxDrawRectangle(self.x + 63*px, self.y + 100*px, self.editWeight, 30*px,tocolor(r,g,b,200))
	end

	if getKeyState("mouse1") then
		if isCursor(self.x + 63*px, self.y + 100*px, self.editWeight, 30*px) then
			self.typing = true
		else
			self.typing = false
		end
	end

	dxDrawText(self.edit, self.x + 67*px, self.y + 105*px, self.editWeight, 30*px, tocolor(255,255,255,255),0.5, self.fonts["editbox"])

	local index = 0
	local startY = self.y + 105*px
	for k,v in ipairs(self.traksList) do
		if k >= scroll then
			index = index + 1
			if index <= maxItems then
				dxDrawRectangle(self.x + 63*px, startY + (index* (53*px)), self.editWeight, 45*px,tocolor(r,g,b,255))

				local artist = v.artist
				if utf8.len(artist) >= 45 then
					artist = utf8.sub(artist, 1, 42).."..."
				end
				local title = v.title
				if utf8.len(title) >= 45 then
					title = utf8.sub(title, 1, 42).."..."
				end
				dxDrawText(artist, (self.x + 115*px), (startY + (index* (53*px))) + 2,10,10,tocolor(255,255,255,255),0.5,self.fonts["editbox"])
				dxDrawText(title, (self.x + 115*px), (startY + (index* (53*px))) + 15,10,10,tocolor(255,255,255,255),0.5,self.fonts["editbox"])

				if v.image ~= "none" then
					local Vid = utf8.sub(v.id, 10)
					dxDrawImage(self.x + 63*px, startY + (index* (53*px)), 45*px, 45*px, textures[Vid])
				end

				if isElement(self.currentMusicData) then
					if v == self.playedMusicData then
						if not isSoundPaused(self.currentMusicData) then
							dxDrawImage(self.x + 63*px, startY + (index* (53*px)), 45*px, 45*px, "assets/pause.png")
						else
							dxDrawImage(self.x + 63*px, startY + (index* (53*px)), 45*px, 45*px, "assets/start.png")
						end
					end
				end
			end
		end
	end

	local scrollBarHeight = 256*px
	local scrollBarY = ((scroll* (53*px)) / ((#self.traksList - 1)* (53*px)) * scrollBarHeight)
	dxDrawRectangle((self.x + self.w) - 65*px, startY + 53*px, 10*px, scrollBarHeight,tocolor(50,50,50,255))

	dxDrawRectangle((self.x + self.w) - 65*px, (startY + 53*px) + scrollBarY, 10*px, 50*px,tocolor(255,0,0,255))

	if isElement(self.currentMusicData) then 
		dxDrawRectangle(self.x + 25*px, (self.y + self.h) - 95*px, self.w - 50*px, 60*px, tocolor(r,g,b,255))
		local Vid = utf8.sub(self.playedMusicData.id, 10)
		if textures[Vid] ~= nil then
			dxDrawImage(self.x + 25*px, (self.y + self.h) - 95*px,60*px,60*px, textures[Vid])
		end
		if not isSoundPaused(self.currentMusicData) then
			dxDrawImage(self.x + 25*px, (self.y + self.h) - 95*px,60*px,60*px, "assets/pause.png")
		else
			dxDrawImage(self.x + 25*px, (self.y + self.h) - 95*px,60*px,60*px, "assets/start.png")
		end

		local title = self.playedMusicData.artist.." - "..self.playedMusicData.title
		if utf8.len(title) >= 45 then
			title = utf8.sub(title, 1, 42).."..."
		end
		dxDrawText(title, (self.x + 90*px), (self.y + self.h) - 90*px, 10,10,tocolor(255,255,255,255),0.5,self.fonts["header"])

		local length = getSoundLength(self.currentMusicData)
		local currentPosition = getSoundPosition(self.currentMusicData)
		local lineWeight = self.w - 110*px
		local proccesWeight = (currentPosition/length)*lineWeight
		local lineX = self.x + 85*px
		local bufferWeight = (getSoundBufferLength(self.currentMusicData)/length) * lineWeight

		local r,g,b = unpack(self.colors["main_color"])
		if not (proccesWeight ~= proccesWeight) then
			dxDrawRectangle(lineX, ((self.y + self.h) - 47*px), lineWeight, 10*px, tocolor(60,60,60,255))
			dxDrawRectangle(lineX, ((self.y + self.h) - 47*px), bufferWeight, 10*px, tocolor(40,40,40,255))
			dxDrawRectangle(lineX, ((self.y + self.h) - 47*px), proccesWeight, 10*px, tocolor(r,g,b,255))
		end
		
		local playedTime = string.format("%02d:%02d / %02d:%02d", currentPosition/60, currentPosition % 60, length/60, length % 60)
		dxDrawText(playedTime, (self.x + 90*px),(self.y + self.h) - 70*px, 10,10,tocolor(255,255,255,255),0.5,self.fonts["header"])

		if isCursor(lineX, ((self.y + self.h) - 47*px), lineWeight, 10*px) then
			if getKeyState("mouse1") then
				local mx, my = getCursorPosition()
				mx, my = mx*sx, my*sy
				local posX = math.abs(lineX - mx)
				local newPosition = (posX / lineWeight) * length
				setSoundPosition(self.currentMusicData, newPosition)
			end
		end
	end
end

addEventHandler("onClientClick", root, function(key, state)
	if not self.state then return end
	if key == "left" and state == "down" then
		local index = 0
		local startY = self.y + 105*px
		for k,v in ipairs(self.traksList) do
			if k >= scroll then
				index = index + 1
				if index <= maxItems then
					if isCursor(self.x + 63*px, startY + (index* (53*px)), 45*px, 45*px) then
						if v == self.playedMusicData then
							setSoundPaused(self.currentMusicData, not isSoundPaused(self.currentMusicData))
						else
							self.play(k)
							self.playedMusicData = v
						end
					end
				end
			end
		end
		if isCursor(self.x + 25*px, (self.y + self.h) - 95*px, 60*px, 60*px) then
			if isElement(self.currentMusicData) then
				setSoundPaused(self.currentMusicData, not isSoundPaused(self.currentMusicData))
			end
		end
	end
end)

function self.visible(state)
	self.state = state
	showCursor(state);
	if state then
		guiSetInputMode("no_binds")
		addEventHandler("onClientRender", root, radioRender)
	else
		guiSetInputMode("allow_binds")
		removeEventHandler("onClientRender", root, radioRender)
	end
end

addEventHandler("onClientKey", root, function(key,state)
	if key == self.key and not state then
		if self.typing then return end
		self.visible(not self.state)
	end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
	guiSetInputMode("allow_binds")
end)

function self.sendResult(resultTable)
	scroll = 0
	for k,v in ipairs(textures) do
		v:destroy()
		textures[k] = nil
	end
	local tempTable = {};
	for k,v in ipairs(resultTable) do
		table.insert(tempTable, {
			id = v.id,
			artist = v.artist,
			title = v.title,
			url = v.url,
			image = "none",
		})
	end
	self.traksList = tempTable
end

function self.sendImage(id, pixels)
	for k,v in ipairs(self.traksList) do
		local Vid = utf8.sub(v.id, 10)
		if Vid == id then
			if textures[Vid] ~= nil then
				textures[Vid]:destroy()
				textures[Vid] = nil
			end
			textures[Vid] = dxCreateTexture(pixels)
			self.traksList[k].image = textures[Vid]
		end
	end
end

function self.play(index)
	if isElement(self.currentMusicData) then
		stopSound(self.currentMusicData)
	end
	if self.traksList[index] == nil then return end
	self.currentMusicData = playSound(self.traksList[index].url)
end

addEventHandler("onClientKey", root, function(key,state)
	if state then
		if key == "mouse_wheel_up" then
			if scroll > 1 then
				scroll = scroll - 1
			end
		end
		if key == "mouse_wheel_down" then
			if (#self.traksList - 5) > 0 then
				if scroll < (#self.traksList - 5) then
					scroll = scroll + 1
				end
			end
		end
	end
end)
