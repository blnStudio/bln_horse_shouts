RegisterNetEvent(GetCurrentResourceName()..":sv_playVoice")
AddEventHandler(GetCurrentResourceName()..":sv_playVoice", function(riderPed_net, voiceLine)
    TriggerClientEvent(GetCurrentResourceName()..":cl_playVoice", -1, riderPed_net, voiceLine)
end)