local timeSinceSpeech = 0
local mounted = false
local lastCmd = -1

-- Command types
local CMD_TYPES = {
    SPRINT = 0,
    PAT = 1,
    JUMP = 2
}

-- Control mappings
local CONTROLS = {
    SPRINT = {control = "INPUT_HORSE_SPRINT", key = 0x5AA007D7},
    JUMP = {control = "INPUT_HORSE_JUMP", key = 0xE4D2CE1D}
}

-- Event Groups
local EVENT_GROUPS = {
    AI = 0,           -- SCRIPT_EVENT_QUEUE_AI
    NETWORK = 1,      -- SCRIPT_EVENT_QUEUE_NETWORK
    SCRIPT = 2,       -- SCRIPT_EVENT_QUEUE_SCRIPT
    UI = 3            -- SCRIPT_EVENT_QUEUE_UI
}

local function IsPedMale(ped)
    return Citizen.InvokeNative(0x95B8E397B8F4360F, ped)
end

local function GetRandomVoiceLine(voiceType)
    local playerPed = PlayerPedId()
    local gender = IsPedMale(playerPed) and "male" or "female"
    
    local voices = Config.VoiceLines[gender][voiceType]
    if voices and #voices > 0 then
        return voices[math.random(#voices)]
    end
    return nil
end

local function ShouldSpeak()
    return math.random(100) <= Config.ChanceToSpeak
end

local function CanSpeak()
    return timeSinceSpeech >= Config.MinTimeBetweenVoices
end

function PlayAmbientSpeechFromEntity(entity_id, sound_ref_string, sound_name_string, speech_params_string, speech_line)
    local sound_name = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", sound_name_string, Citizen.ResultAsLong())
    local sound_ref = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", sound_ref_string, Citizen.ResultAsLong())
    local speech_params = GetHashKey(speech_params_string)
    
    local sound_name_BigInt = DataView.ArrayBuffer(16) 
    sound_name_BigInt:SetInt64(0, sound_name)
    
    local sound_ref_BigInt = DataView.ArrayBuffer(16)
    sound_ref_BigInt:SetInt64(0, sound_ref)
    
    local speech_params_BigInt = DataView.ArrayBuffer(16)
    speech_params_BigInt:SetInt64(0, speech_params)
    
    local struct = DataView.ArrayBuffer(128)
    struct:SetInt64(0, sound_name_BigInt:GetInt64(0))
    struct:SetInt64(8, sound_ref_BigInt:GetInt64(0))
    struct:SetInt32(16, speech_line)
    struct:SetInt64(24, speech_params_BigInt:GetInt64(0)) 
    struct:SetInt32(32, 0)
    struct:SetInt32(40, 1) 
    struct:SetInt32(48, 1) 
    struct:SetInt32(56, 1)
    
    return Citizen.InvokeNative(0x8E04FEDD28D42462, entity_id, struct:Buffer())
end

-- Play voice line
local function PlayVoiceLine(ped, voiceLine)
    if not ped or not voiceLine then return end
    if type(voiceLine) ~= "table" or #voiceLine ~= 2 then
        print("Invalid voice line format")
        return
    end
    
    PlayAmbientSpeechFromEntity(ped, voiceLine[1], voiceLine[2], "speech_params_force", 0)
end

local function HandleVoiceCommand(cmdType)
    if not CanSpeak() or not ShouldSpeak() then return end
    
    local playerPed = PlayerPedId()
    local horse = GetMount(playerPed)
    
    if cmdType == CMD_TYPES.PAT and not horse then
        horse = GetLastMount(playerPed)
    end
    
    if not horse then return end
    
    local voiceType
    if cmdType == CMD_TYPES.SPRINT then
        voiceType = "sprint"
    elseif cmdType == CMD_TYPES.PAT then
        voiceType = "pat"
    elseif cmdType == CMD_TYPES.JUMP then
        voiceType = "jump"
    end
    
    local voiceLine = GetRandomVoiceLine(voiceType)
    if voiceLine then
        TriggerServerEvent(GetCurrentResourceName()..':sv_playVoice', PedToNet(playerPed), voiceLine)
        timeSinceSpeech = 0
        lastCmd = cmdType
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        mounted = IsPedOnMount(playerPed)
        
        if mounted then
            timeSinceSpeech = timeSinceSpeech + GetFrameTime()
            
            if IsControlJustPressed(0, CONTROLS.SPRINT.key) then
                HandleVoiceCommand(CMD_TYPES.SPRINT)
            end
            
            if IsControlJustPressed(0, CONTROLS.JUMP.key) then
                HandleVoiceCommand(CMD_TYPES.JUMP)
            end
        end

        local size = GetNumberOfEvents(EVENT_GROUPS.AI)
        
        if size > 0 then
            for i = 0, size - 1 do
                local eventAtIndex = GetEventAtIndex(EVENT_GROUPS.AI, i)
                
                -- Check for EVENT_CALM_PED (patting/calming horse)
                if eventAtIndex == GetHashKey("EVENT_CALM_PED") then
                    local eventDataStruct = DataView.ArrayBuffer(8 * 4)
                    local isDataExists = Citizen.InvokeNative(0x57EC5FA4D4D6AFCA, EVENT_GROUPS.AI, i, eventDataStruct:Buffer(), 4)
                    
                    if isDataExists then
                        local calmerPedId = eventDataStruct:GetInt32(0)
                        local mountPedId = eventDataStruct:GetInt32(8)
                        local calmType = eventDataStruct:GetInt32(16)
                        local isFullyCalmed = eventDataStruct:GetInt32(24)
                        
                        if calmerPedId == PlayerPedId() then
                            HandleVoiceCommand(CMD_TYPES.PAT)
                        end
                    end
                end
            end
        end

    end
end)



RegisterNetEvent(GetCurrentResourceName()..":cl_playVoice")
AddEventHandler(GetCurrentResourceName()..":cl_playVoice", function(riderPed_net, voiceLine)
    local riderPed = NetToPed(riderPed_net)
    if riderPed and voiceLine then
        PlayVoiceLine(riderPed, voiceLine)
    end
end)