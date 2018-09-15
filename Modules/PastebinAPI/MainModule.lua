-- PastebinAPI, by Kiansjet

local mod				= {}

	  mod.apiKey		= nil
	  mod.userKey		= nil
	  mod.bodyLengthCap	= 524288 -- About half of Roblox's data packet size limit as of 1/31/18

local GET				= function(url) return game:GetService('HttpService'):GetAsync(url) end
local POST				= function(url,data) return game:GetService('HttpService'):PostAsync(url,data,Enum.HttpContentType.ApplicationUrlEncoded) end
local toJSON			= function(tab) return game:GetService('HttpService'):JSONEncode(tab) end
local urlEncode			= function(str) return game:GetService('HttpService'):UrlEncode(str) end

local rawGetUrl			= 'https://pastebin.com/raw/'
local apiRawGetUrl		= 'https://pastebin.com/api/api_raw.php'
local loginUrl			= 'https://pastebin.com/api/api_login.php'
local postUrl			= 'https://pastebin.com/api/api_post.php'

local apiError			= 'Bad API request'
local findRawError		= 'Error with this ID'

local needApiKeyError	= 'Error in preprocessing: Please define module.apiKey first. (You can get one at pastebin.com/api)'
local needUserKeyError	= 'Error in preprocessing: Please define module.userKey first. You can generate one with module.GetUserKeyAsync()'

do -- HttpEnabled check (Why the f*** is there LocalUserSecurity on HttpEnabled for crap's sake)
	local s,m = pcall(function()
		GET('oof')
	end)
	if not s and m == 'Http requests are not enabled. Enable via game settings' then
		warn('Darn... Looks like Http communications arent enabled...')
		return nil
	end
end

local function filter(raw)
	if string.sub(raw,1,#apiError) == apiError then
		return false,'Error on Pastebin side: '..raw
	elseif raw == findRawError then
		return false,'Error on Pastebin side: '..raw
	end
	return true,raw
end

function mod.GetUserKeyAsync(username,password)
	if not mod.apiKey then
		return false,needApiKeyError
	end
	if type(username) ~= 'string' then
		return false,'Error in preprocessing: Username must be a STRING. ('.. type(username)..' provided)'
	end
	if type(password) ~= 'string' then
		return false,'Error in preprocessing: Password must be a STRING. ('.. type(password)..' provided)'
	end
	
	local data = 'api_dev_key='..urlEncode(mod.apiKey)..'&api_user_name='..urlEncode(username)..'&api_user_password='..urlEncode(password)
	local key
	local s,m = pcall(function()
		key = POST(loginUrl,data)
	end)
	if not s then
		return s,'Error during POST: '..m
	end
	if key then
		return filter(key)
	else
		return false,'Error [Undocumented]: Returned login key was nil'
	end
end

function mod.DeletePasteAsync(pasteId)
	if not mod.apiKey then
		return false,needApiKeyError
	end
	if not mod.userKey then
		return false,needUserKeyError
	end
	if type(pasteId) ~= 'string' then
		return false,'Error in preprocessing: PasteId must be a STRING. ('.. type(pasteId)..' provided)'
	end
	local data = 'api_option=delete&api_dev_key='..urlEncode(mod.apiKey)..'&api_user_key='..urlEncode(mod.userKey)..'&api_paste_key='..urlEncode(pasteId)
	local confirmation
	local s,m = pcall(function()
		confirmation = POST(postUrl,data)
	end)
	if not s then
		return false,'Error during POST: '..m
	end
	if confirmation then
		if confirmation == 'Paste Removed' then
			return true,confirmation
		else
			return filter(confirmation)
		end
	else
		return false,'Error [Undocumented]: Response was nil'
	end
end

function mod.PasteAsync(body,name,format,privacy,expiration)
	if not mod.apiKey then
		return false,needApiKeyError
	end
	if type(body) ~= 'string' or #body > mod.bodyLengthCap then
		return false,'Error in preprocessing: Body must be a STRING AND needs to be <= '..mod.bodyLengthCap..' characters.'
	end
	name = name or 'Paste from: https://www.roblox.com/games/'..tostring(game.PlaceId)
	format = format or 'lua'
	privacy = privacy or 0
	expiration = expiration or 'N'
	
	if type(name) ~= 'string' or #name > 50 then
		return false,'Error in preprocessing: Name must be a STRING and MUST be <= 50 characters.'
	end
	if type(format) ~= 'string' then
		return false,'Error in preprocessing: Format must be a STRING and MUST be one of the formats accepted on this page: https://pastebin.com/api#5'
	end
	if type(privacy) ~= 'number' then
		return false,'Error in preprocessing: Privacy must be a NUMBER and MUST be one of the formats accepted on this page: https://pastebin.com/api#7'
	end
	privacy = tostring(math.floor(math.clamp(privacy,0,2)))
	if type(expiration) ~= 'string' then
		return false,'Error in preprocessing: Expiration must be a STRING and MUST be one of the formats accepted on this page: https://pastebin.com/api#7'
	end
	
	local data = 'api_dev_key='..urlEncode(mod.apiKey)..'&api_option=paste&api_paste_code='..urlEncode(body)..'&api_paste_name='..urlEncode(name)..'&api_paste_format='..urlEncode(format)..'&api_paste_private='..urlEncode(privacy)..'&api_paste_expire_date='..urlEncode(expiration)
	if mod.userKey then
		data = data..'&api_user_key='..urlEncode(mod.userKey)
	end
	local url
	local s,m = pcall(function()
		url = POST(postUrl,data)
	end)
	if not s then
		return false,'Error during POST: '..m
	end
	if url then
		return filter(url)
	else
		return false,'Error [Undocumented]: Response was nil'
	end
end

function mod.ApiGetPasteAsync(pasteId)
	if not mod.apiKey then
		return false,needApiKeyError
	end
	if not mod.userKey then
		return false,needUserKeyError
	end
	if type(pasteId) ~= 'string' then
		return false,'Error in preprocessing: PasteId must be a STRING. ('.. type(pasteId)..' provided)'
	end
	local data = 'api_option=show_paste&api_dev_key='..urlEncode(mod.apiKey)..'&api_user_key='..urlEncode(mod.userKey)..'&api_paste_key='..urlEncode(pasteId)
	local raw
	local s,m = pcall(function()
		raw = POST(apiRawGetUrl,data)
	end)
	if not s then
		return s,'Error during POST: '..m
	end
	if raw then
		return filter(raw)
	else
		return false,'Error [Undocumented]: Raw API response was nil.'
	end
end

function mod.GetPasteAsync(pasteId)
	if type(pasteId) ~= 'string' then
		return false,'Error in preprocessing: PasteId must be a STRING. ('.. type(pasteId)..' provided)'
	end
	local raw
	local s,m = pcall(function()
		raw = GET(rawGetUrl..pasteId)
	end)
	if not s then
		return s,'Error during GET: '..m
	end
	if raw then
		return filter(raw)
	else
		return false,'Error [Undocumented]: Raw response was nil. Try using module.ApiGetPasteAsync() for private pastes.'
	end
end

return mod

-- END PastebinAPI, by Kiansjet
