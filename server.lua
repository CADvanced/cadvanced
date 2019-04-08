local url = "https://192.168.0.101:4000/api";

allCalls = {}
allUnits = {}
userUnits = {}

-- Grab all calls
function getAllCalls()
    local callPayload = {  
        operationName = null,
        variables = {},
        query = "{ allCalls { id callerInfo markerX markerY callGrade { name } callType { name } callLocations { name } callIncidents { name } } }"
    };
    local callToSend = json.encode(callPayload)
    PerformHttpRequest(
        url,
        function (errorCode, resultData, resultHeaders)
            if errorCode ~= 200 then
                print('CADVanced: ERROR - Unable to retrieve all calls, error code ' .. errorCode)
                return errorCode
            end
            allCalls = json.decode(resultData)
            print("CADvanced: Retrieved all calls")
        end,
        'POST',
        callToSend,
        { ["Content-Type"] = 'application/json' }
    )
end

-- Grab all units
function getAllUnits()
    local callPayload = {  
        operationName = null,
        variables = {},
        query = "{  allUnits { callSign unitType { name } unitState { name colour } } }"
    }
    local unitToSend = json.encode(callPayload)
    PerformHttpRequest(
        url,
        function (errorCode, resultData, resultHeaders)
            if errorCode ~= 200 then
                print('CADvanced: ERROR - Unable to retrieve all units, error code ' .. errorCode)
                return errorCode
            end
            allUnits = json.decode(resultData)
            print("CADvanced: Retrieved all units")
        end,
        'POST',
        unitToSend,
        { ["Content-Type"] = 'application/json' }
    )
end

-- Grab users units and calls
function getUser(source)
    local id = getSteamId(source)
    local userPayload = {
        operationName = null,
        query = '{ getUser(steamId: "' .. id .. '") { units { callSign unitType { name } unitState { name } assignedCalls { callerInfo markerX markerY callIncidents { name } callType { name } callGrade { name } callLocations { name } callDescriptions { text } } } } }'
    }
    local reqToSend = json.encode(userPayload)
    PerformHttpRequest(
        url,
        function (errorCode, resultData, resultHeaders)
            if errorCode ~= 200 then
                print('CADvanced: ERROR - Unable to retrieve user units, error code ' .. errorCode)
                return errorCode
            end
            userUnits[id] = json.decode(resultData)
            print("CADvanced: Retrieved all user units for joined user")
        end,
        'POST',
        reqToSend,
        { ["Content-Type"] = 'application/json' }
    )
end

-- Rudimentary router
SetHttpHandler(function(req, res)
    if req.method == 'POST' then
        -- POST routes
        if req.path == '/player_update' then
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

RegisterServerEvent('playerConnecting')
AddEventHandler('playerConnecting', function()
    validate(source)
    getUser(source)
end)

-- Initial population
getAllCalls()
getAllUnits()