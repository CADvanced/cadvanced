local url = "https://alpha.cadvanced.app:4000/api";
local ids = {}

RegisterServerEvent('cv:updatePosition')
AddEventHandler('cv:updatePosition', function(x, y, z)
    local Source = source
    Citizen.CreateThread(function()
            for k,v in ipairs(GetPlayerIdentifiers(Source)) do
				if string.sub(v, 1, string.len("steam:")) == "steam:" then
					local id = v:gsub("steam:","")
                    local payload = {  
                        operationName = null,
                        variables = {  
                            steamId = id,
                            x = x,
                            y = y
                        },
                        query = "mutation ($steamId: String!, $x: String!, $y: String!) {\n  updateUserLocation(steamId: $steamId, x: $x, y: $y) {\n    id\n    __typename\n  }\n}\n"
                    };
					local tosend = json.encode(payload)
					PerformHttpRequest(url, function(errorCode, resultData, resultHeaders)
						print (tostring(resultData))
						end,
						'POST',
						tosend,
						{ ["Content-Type"] = 'application/json' }
					)
					break
				end
            end
    end)
end)

local validate = function(source)
	local id
	for k,v in ipairs(GetPlayerIdentifiers(source))do
		if string.sub(v, 1, string.len("steam:")) == "steam:" then
			id = v
			break
		end
	end

	if not id then
		setKickReason("Unable to find SteamID, please relaunch FiveM with steam open or restart FiveM & Steam if steam is already open")
		CancelEvent()
	end
end

RegisterServerEvent('cv:firstJoinProper')
AddEventHandler('cv:firstJoinProper', function()
	validate(source)
end)

RegisterServerEvent('playerConnecting')
AddEventHandler('playerConnecting', function()
	validate(source)
end)

