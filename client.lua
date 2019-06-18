local oldPos
local blips = {}
local cadActive = false
local userDisplayedCad = false

local showCad = function()
    TriggerServerEvent('cv:passUnits')
    TriggerServerEvent('cv:passUser')
    TriggerServerEvent('cv:passConfig')
    SendNUIMessage({
      type = "show",
      toShow = "cad"
    })
    cadActive = true
end

local hideCad = function()
    SendNUIMessage({
      type = "hide",
      toHide = "cad"
    })
    cadActive = false
end

local removeBlips = function()
    for b,blip in pairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}
end

local setBlips = function(assignedCalls)
    blips = {}
    for j,c in ipairs(assignedCalls) do
        local markerX = c.markerX
        local markerY = c.markerY
        if (markerX and markerY) then
            local blip = AddBlipForCoord(markerX, markerY)
            SetBlipSprite(blip, 398)
            SetBlipColour(blip, 0)
            SetBlipDisplay(blip, 2)
            SetBlipAsShortRange(blip, false)
            BeginTextCommandSetBlipName("String")
            AddTextComponentString(c.callType.name .. ' - ' .. c.callGrade.name)
            EndTextCommandSetBlipName(blip)
            blips[c.id] = blip
        end
    end
end

Citizen.CreateThread(function()
    while true do
        local pos = GetEntityCoords(GetPlayerPed(-1))
        if (oldPos ~= pos) then
            TriggerServerEvent('cv:updatePosition', pos.x, pos.y, pos.z)
            oldPos = pos
        end
        Citizen.Wait(5000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlPressed(1, 21) and IsControlJustPressed(1, 40) then
            if (cadActive) then
                hideCad()
                userDisplayedCad = false
            else
                showCad()
                userDisplayedCad = true
            end 
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsPauseMenuActive() then
            if cadActive then
                hideCad()
            end
        else
            if userDisplayedCad and not cadActive then
                showCad()
            end
        end
    end
end)

-- Receive all units object from the server then pass it to NUI
RegisterNetEvent('data:units')
AddEventHandler('data:units', function(jsonData)
    -- Create blips for any calls that have them
    -- First remove any existing blips
    Citizen.CreateThread(function()
        removeBlips()
        -- Now populate the blips
        for i,u in ipairs(jsonData.data.usersUnits) do
            setBlips(u.assignedCalls)
        end
    end)
    -- Pass data to NUI
    SendNUIMessage({
      type = "units",
      units = jsonData
    })
end)

-- Receive user object from the server then pass it to NUI
RegisterNetEvent('data:user')
AddEventHandler('data:user', function(jsonData)
    -- Pass data to NUI
    SendNUIMessage({
      type = "user",
      user = jsonData
    })
end)

-- Receive config object from the server then pass it to NUI
RegisterNetEvent('data:config')
AddEventHandler('data:config', function(jsonData)
    -- Pass data to NUI
    SendNUIMessage({
      type = "config",
      config = jsonData
    })
end)

RegisterNetEvent('msg:updateMsg')
AddEventHandler('msg:updateMsg', function(payload)
    -- Pass data to NUI
    SendNUIMessage({
        type = "message",
        payload = payload
    })
end)

RegisterNetEvent('event:refetchUnits')
AddEventHandler('event:refetchUnits', function()
    TriggerServerEvent('cv:passUnits')
end)
