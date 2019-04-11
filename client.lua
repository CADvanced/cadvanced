local oldPos

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
            TriggerServerEvent('cv:getUser')
        end
    end
end)

RegisterNetEvent('data:user')
AddEventHandler('data:user', function(jsonData)
    Citizen.Trace(jsonData)
    -- Pass data to NUI
    SendNUIMessage({
      type = "data",
      data = jsonData
    })

end)

RegisterNetEvent('msg:updateMsg')
AddEventHandler('msg:updateMsg', function(message)
    -- Change to
    -- https://forum.fivem.net/t/switching-from-chatmessage-to-chat-addmessage/373482
    TriggerEvent('chatMessage', "", {255, 255, 255}, message)
end)