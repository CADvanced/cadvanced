local url = "https://192.168.0.101:4000/api";

local allUnits = {}

local passToClient = function(source, jsonData, type)
    print('Passing ' .. type .. ' to client')
    local targetUser
    if source then
        targetUser = source
    else
        targetUser = -1
    end
    TriggerClientEvent(
        "data:"..type,
        targetUser,
        jsonData
    )
end

-- Grab all units
function getAllUnits(pass)
    local unitPayload = {  
        operationName = null,
        variables = {},
        query = "{allUnits{callSign users{id}unitType{name}unitState {name colour}assignedCalls{id callerInfo markerX markerY callGrade{name}callType {name}callLocations {name}callIncidents{name}}}}"
    }
    local queryToSend = json.encode(unitPayload)
    PerformHttpRequest(
        url,
        function (errorCode, resultData, resultHeaders)
            if errorCode ~= 200 then
                print('CADvanced: ERROR - Unable to retrieve all units, error code ' .. errorCode)
                return errorCode
            end
            allUnits = json.decode(resultData)
            if pass then
                passToClient(nil, allUnits, 'units')
            end
            print("CADvanced: Retrieved all units")
        end,
        'POST',
        queryToSend,
        { ["Content-Type"] = 'application/json' }
    )
end

-- Rudimentary router
SetHttpHandler(function(req, res)
    if req.method == 'POST' then
        -- POST routes
        if req.path == '/update' then
            req.setDataHandler(function(body)
                local data = json.decode(body)
                if (data.event == 'update' and data.object == 'units') then
                    -- Get all the units and pass them to the client
                    getAllUnits(1)
                end
                res.send(
                    json.encode({ result = 'Message sent'})
                )
            end)
        elseif req.path == '/player_update' then
            req.setDataHandler(function(body)
                local data = json.decode(body)
                if data.event == 'addedToUnit' then
                    local toPlayerIds = data.toPlayerIds
                    local unitId = data.unitId
                    TriggerClientEvent(
                        "player:addedToUnit",
                        unitId    
                    )
                elseif data.event == 'removedFromUnit' then
                    local toPlayerIds = data.toPlayerIds
                    local unitId = data.unitId
                    -- TODO: Dispatch to handler for removing from unit
                end
                --TriggerClientEvent(
                --    "msg:updateMsg",
                --    -1,
                --    'CADvanced: ' .. data.msg
                --)
                res.send(
                    json.encode({ result = 'Message sent'})
                )
            end)
        elseif req.path == '/unit_update' then
            req.setDataHandler(function(body)
                local data = json.decode(body)
                if data.event == 'addedToCall' then
                    local toPlayerIds = data.toPlayerIds
                    local callId = data.callId
                    print(data)
                    -- TODO: Dispatch to handler for assigning to call
                elseif data.event == 'removedFromCall' then
                    local toPlayerIds = data.toPlayerIds
                    local callId = data.callId
                    -- TODO: Dispatch to handler for assigning from unit
                end
            end)
        elseif req.path == '/special_event' then
            req.setDataHandler(function(body)
                local data = json.decode(body)
                if data.event == 'panic' then
                    local toPlayerIds = data.toPlayerIds
                    local sourcePlayerId = data.sourcePlayerId
                end
            end)
        end
    end
end)

-- Grab user and pass to client
function getUser(source)
    print('Getting user')
    local id = getSteamId(source)
    local userPayload = {
        operationName = null,
        query = '{ getUser(steamId: "' .. id .. '") { id steamId userName avatarUrl } }'
    }
    local reqToSend = json.encode(userPayload)
    PerformHttpRequest(
        url,
        function (errorCode, resultData, resultHeaders)
            if errorCode ~= 200 then
                print('CADvanced: ERROR - Unable to retrieve user units, error code ' .. errorCode)
                return errorCode
            end
            passToClient(source, json.decode(resultData), 'user')
            print("CADvanced: Retrieved user");
        end,
        'POST',
        reqToSend,
        { ["Content-Type"] = 'application/json' }
    )
end

-- Get the player's Steam ID
function getSteamId(source)
	local id = nil
	for k,v in ipairs(GetPlayerIdentifiers(source))do
		if string.sub(v, 1, string.len("steam:")) == "steam:" then
            local trimmed = v:gsub("steam:","")
			id = trimmed
			break
		end
    end
    return id
end

-- Check if a user has a SteamID
local validate = function(source)
    local id = getSteamId(source)
	if not id then
		setKickReason("Unable to find SteamID, please relaunch FiveM with steam open or restart FiveM & Steam if steam is already open")
		CancelEvent()
	end
end

-- Pass the client the units when requested
RegisterServerEvent('cv:passUnits')
AddEventHandler('cv:passUnits', function()
    -- We already have them, so we don't need to get them
    passToClient(source, allUnits, 'units')
end)

-- Pass the client the user when requested
RegisterServerEvent('cv:passUser')
AddEventHandler('cv:passUser', function()
    -- This call gets them a returns them to the client, since we don't
    -- hold this data ourselves
    getUser(source)
end)

-- Validate a user when they connect
RegisterServerEvent('playerConnecting')
AddEventHandler('playerConnecting', function()
    validate(source)
end)

-- Send a player's location when prompted to
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

-- Initial population
getAllUnits()