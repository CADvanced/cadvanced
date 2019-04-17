local oldPos

local toggleCad = function()
    TriggerServerEvent('cv:passUnits')
    TriggerServerEvent('cv:passUser')
    SendNUIMessage({
      type = "toggle",
      toToggle = "cad"
    })
end

Citizen.CreateThread(function()
    while true do
        local pos = GetEntityCoords(GetPlayerPed(-1))
        if (oldPos ~= pos)then
            TriggerServerEvent('cv:updatePosition', pos.x, pos.y, pos.z)
            oldPos = pos
        end
        Citizen.Wait(5000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlPressed(1, 21) and IsControlJustPressed(1, 26) then
            toggleCad()
        end
    end
end)

-- Receive all units object from the server then pass it to NUI
RegisterNetEvent('data:units')
AddEventHandler('data:units', function(jsonData)
    print('Passing units to NUI')
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

--[[
RegisterNetEvent('msg:updateMsg')
AddEventHandler('msg:updateMsg', function(message)
    -- Change to
    -- https://forum.fivem.net/t/switching-from-chatmessage-to-chat-addmessage/373482
    TriggerEvent('chatMessage', "", {255, 255, 255}, message)
end)
--]]