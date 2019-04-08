local oldPos

local calls = {}
local units = {}

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

RegisterNetEvent('msg:updateMsg')
AddEventHandler('msg:updateMsg', function(message)
    -- Change to
    -- https://forum.fivem.net/t/switching-from-chatmessage-to-chat-addmessage/373482
    TriggerEvent('chatMessage', "", {255, 255, 255}, message)
end)

RegisterNetEvent('player:addedToUnit');
AddEventHandler('player:addedToUnit', function(unit)
    table.insert(calls, unit)
    print(calls)
end)
