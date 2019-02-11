local url = "https://cadvanced.warmlight.co.uk:4000/";
local ids = {}

RegisterServerEvent('cv:updatePosition')
AddEventHandler('cv:updatePosition', function()
    local Source = source
    Citizen.CreateThread(function()
        --    while true do
            ids = GetPlayerIdentifiers(source)
            for num,id in ipairs(ids) do
                print (id)
                --        if string.sub(v, 1, string.len("steam:")) == "steam:" then
                print (v)
                --            break
                --        end
            end
            --    PerformHttpRequest(url, function(errorCode, resultData, resultHeaders)
            --        print (tostring(resultData))
            --    end)
            --    Citizen.Wait(5000)
        --    end
    end)

end)

RegisterServerEvent('cv:firstJoinProper')
AddEventHandler('cv:firstJoinProper', function()
    local Source = source
    Citizen.CreateThread(function()
        local id
        for k,v in ipairs(GetPlayerIdentifiers(Source))do
            if string.sub(v, 1, string.len("steam:")) == "steam:" then
                id = v
                break
            end
        end

        if not id then
            DropPlayer(Source, "SteamID not found, please try reconnecting with Steam open.")
        else
            registerUser(id, Source)
            justJoined[Source] = true

            if(settings.defaultSettings.pvpEnabled)then
                TriggerClientEvent("es:enablePvp", Source)
            end
        end

        return
    end)
end)


