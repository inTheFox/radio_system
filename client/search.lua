--Radio Search

function getItemData(item)
	local startPos = utf8.find(item, "{");
	local endPos = utf8.find(item, "}");
	if startPos and endPos then else return end
	local musicTable = fromJSON(utf8.sub(item, startPos, endPos))
	return musicTable
end

function downloadImageCallback(data,_, player,id)
	triggerEvent("radio.sendImage",resourceRoot, data, id)
end

function searhCallback(result,_, player)
	local sendTable = {};
	local start = utf8.find(result, '<ul class="tracks__list">')
	local text
	local endpos = 0
	local soundsCount = 0

	if start then
		text = utf8.sub(result, start)
		local musics = utf8.gmatch(text, 'class="tracks__item track mustoggler"')
		for k in musics do
			local start, endPosition = utf8.find(text, k, endpos)
			local _, endPositionB = utf8.find(text, "</li>", start)
			local currentSection = utf8.sub(text, start, endPositionB)

			endpos = endPosition
			soundsCount = soundsCount + 1
			table.insert(sendTable, getItemData(currentSection))
		end
	end
	if soundsCount > 0 then
		triggerEvent("radio.sendResult", resourceRoot, sendTable)
		for k,v in ipairs(sendTable) do
			local id = utf8.sub(v.id, 10)
			fetchRemote("https://ruq.hotmo.org/"..v.img, downloadImageCallback, "", false, player, id)
		end
	end
end

function RadioGetResult(text)
	for k,v in ipairs(getRemoteRequests(getThisResource())) do
		abortRemoteRequest(v)
	end
	fetchRemote("https://ruq.hotmo.org/search?q="..utf8.gsub(text, " ", "+"), searhCallback, "", false,client)
end
