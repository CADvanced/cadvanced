local oldPos

Citizen.CreateThread(function()
    while true do
        local pos = GetEntityCoords(GetPlayerPed())
        if (oldPos ~= pos)then
            TriggerServerEvent('cv:updatePosition', pos.x, pos.y, pos.y)
            oldPos = pos
        end
        Citizen.Wait(5000)
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if NetworkIsSessionStarted() then
			TriggerServerEvent('cv:firstJoinProper')
			TriggerEvent('cv:allowedToSpawn')
			return
		end
	end
end)
