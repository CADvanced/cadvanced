-- Config values
local url = "https://<your_cadvanced_url_here>" -- The full URL of your CADvanced
local useWhitelist = true -- Only allow people with the "Player" role to join
local soundVolume = 0.5   -- A value between 0 and 1


-- DO NOT EDIT ANYTHING BELOW THIS LINE

local version = "1.0.0"
local whitelisted = {}

-- Generic "check if value is in array" function
local function hasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

local passToClient = function(source, jsonData, type)
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
function getAllUnits(source)
    local id = getSteamId(source)
    local unitPayload = {  
        operationName = null,
        query = '{usersUnits(steamId:"' .. id .. '"){id callSign unitType{name}unitState {name colour}assignedCalls{id callerInfo markerX markerY callGrade{name}callType {name}callLocations {name}callIncidents{name}callDescriptions{text}}}}'
    }
    local queryToSend = json.encode(unitPayload)
    PerformHttpRequest(
        url .. '/api',
        function (errorCode, resultData, resultHeaders)
            if errorCode ~= 200 then
                print('CADvanced: ERROR - Unable to retrieve all units, error code ' .. errorCode)
                return errorCode
            end
            passToClient(source, json.decode(resultData), 'units')
        end,
        'POST',
        queryToSend,
        { ["Content-Type"] = 'application/json' }
    )
end

function sendMessageTo(payload)
    local destination = -1
    if payload.type == 'user' then
        if payload.steamId then
            local id = getUserFromSteamId(payload.steamId)
            if id then
                destination = id
            end
        end
    end
    TriggerClientEvent(
        "msg:updateMsg",
        destination,
        payload
    )
end

local getWhitelisted = function()
    whitelisted = {}
    local whitelistPayload = {  
        operationName = null,
        query = '{allWhitelisted{steamId}}'
    }
    local queryToSend = json.encode(whitelistPayload)
    PerformHttpRequest(
        url .. '/api',
        function (errorCode, resultData, resultHeaders)
            if errorCode ~= 200 then
                print('CADvanced: ERROR - Unable to retrieve whitelisted players, error code ' .. errorCode)
                return errorCode
            end
            local result = json.decode(resultData)
            for _, wl in ipairs(result.data.allWhitelisted) do
                table.insert(whitelisted, wl.steamId);
            end
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
                    -- Prompt each client to refetch it's units
                    TriggerClientEvent("event:refetchUnits", -1)
                elseif (data.event == 'update' and data.object == 'whitelist') then
                    -- Update our whitelist
                    getWhitelisted()
                end
                res.send(
                    json.encode({ result = 'Message sent'})
                )
            end)
        elseif req.path == '/message' then
            req.setDataHandler(function(body)
                local data = json.decode(body)
                sendMessageTo(data)
                res.send(
                    json.encode({ result = 'Message sent'})
                )
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
    local id = getSteamId(source)
    local userPayload = {
        operationName = null,
        query = '{ getUser(steamId: "' .. id .. '") { id steamId userName avatarUrl } }'
    }
    local reqToSend = json.encode(userPayload)
    PerformHttpRequest(
        url .. '/api',
        function (errorCode, resultData, resultHeaders)
            if errorCode ~= 200 then
                print('CADvanced: ERROR - Unable to retrieve user units, error code ' .. errorCode)
                return errorCode
            end
            passToClient(source, json.decode(resultData), 'user')
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

-- Get a user's server Id from their Steam ID
function getUserFromSteamId(steamId)
    local players = GetPlayers()
    -- Iterate all players until we find the one we want
    for _, player in ipairs(players) do
        local id = getSteamId(player)
        if id and id == steamId then
            return player
        end
    end
    return nil
end

-- Check if a user has a SteamID
local validate = function(source, setKickReason)
    local id = getSteamId(source)
    if not id then
        setKickReason("Unable to find SteamID, please relaunch FiveM with steam open or restart FiveM & Steam if steam is already open")
        CancelEvent()
    end
    if useWhitelist and not hasValue(whitelisted, id) then
        setKickReason("You are not whitelisted for this server")
        CancelEvent()
    end
end

-- Pass the client the units when requested
RegisterServerEvent('cv:passUnits')
AddEventHandler('cv:passUnits', function()
    getAllUnits(source)
end)

-- Pass the client the config when requested
RegisterServerEvent('cv:passConfig')
AddEventHandler('cv:passConfig', function()
    -- Return the current config to the user
    passToClient(nil, '{"soundVolume":'..soundVolume..'}', 'config') 
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
AddEventHandler('playerConnecting', function(name, setKickReason)
    validate(source, setKickReason)
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
                    PerformHttpRequest(url .. '/api', function(errorCode, resultData, resultHeaders)
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

getWhitelisted()
