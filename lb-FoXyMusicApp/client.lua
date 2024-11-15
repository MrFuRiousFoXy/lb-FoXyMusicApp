ESX = exports["es_extended"]:getSharedObject()

local identifier = "youtube_music2"

CreateThread(function ()
    while GetResourceState("lb-phone") ~= "started" do
        Wait(500)
    end

    local function AddApp()
        local added, errorMessage = exports["lb-phone"]:AddCustomApp({
            identifier = identifier,
            name = "YouTube Music",
            description = "Play your favorite music",
            developer = "YouTube",
            defaultApp = false,
            size = 59812,
            images = {},
            ui = GetCurrentResourceName() .. "/ui/index.html",
            icon = "https://cfx-nui-" .. GetCurrentResourceName() .. "/ui/assets/icon.png"
        })

        if not added then
            print("Could not add app:", errorMessage)
        end
    end

    AddApp()

    AddEventHandler("onResourceStart", function(resource)
        if resource == "lb-phone" then
            AddApp()
        end
    end)
end)

xSound = exports.xsound
local playing = false
local volume = 50.0
local youtubeUrl = nil
local musicId = "phone_youtubemusic_id_" .. GetPlayerServerId(PlayerId())

RegisterNUICallback("playSound", function(data, cb)
    local plrPed = PlayerPedId()
    local plrCoords = GetEntityCoords(plrPed)
    local url = data.url

    TriggerServerEvent("phone:youtube_music:soundStatus", "play", { position = plrCoords, link = url })
    playing = true
    youtubeUrl = url
end)

RegisterNUICallback("getData", function(data, cb)
    local data = {
        isPlay = playing,
        volume = volume,
        youtubeUrl = youtubeUrl
    }
    cb(data)
end)

RegisterNUICallback("changeVolume", function(data, cb)
    TriggerServerEvent("phone:youtube_music:soundStatus", "volume", { volume = data.volume })
    volume = data.volume
end)

RegisterNUICallback("stopSound", function(data, cb)
    TriggerServerEvent("phone:youtube_music:soundStatus", "stop", {})
    playing = false
end)

RegisterNUICallback("saveSong", function(data, cb)
    TriggerServerEvent("saveSong", data)
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    local pos
    while true do
        Citizen.Wait(100)
        if xSound:soundExists(musicId) and playing then
            if xSound:isPlaying(musicId) then
                pos = GetEntityCoords(PlayerPedId())
                TriggerServerEvent("phone:youtube_music:soundStatus", "position", { position = pos })
            else
                Citizen.Wait(1000)
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

RegisterNetEvent("phone:youtube_music:soundStatus", function(type, musicId, data)
    if type == "position" then
        if xSound:soundExists(musicId) then
            xSound:Position(musicId, data.position)
        end
    elseif type == "play" then
        xSound:PlayUrlPos(musicId, data.link, 1, data.position)
        xSound:destroyOnFinish(musicId, true)
        xSound:setSoundDynamic(musicId, true)
        xSound:Distance(musicId, 20)
    elseif type == "volume" then
        if xSound:soundExists(musicId) then
            data.volume = data.volume / 100
            xSound:setVolumeMax(musicId, data.volume)
        end
    elseif type == "stop" then
        if xSound:soundExists(musicId) then
            xSound:Destroy(musicId)
        end
    end
end)

function GetSavedTracks(citizenid, cb)
    ESX.TriggerServerCallback('getSavedTracks', function(results)
        if results then
            cb(results)
        else
            cb({})
        end
    end, citizenid)
end

RegisterNUICallback("getSavedTracks", function(data, cb)
    local PlayerData = ESX.GetPlayerData()
    if PlayerData then
        local citizenid = PlayerData.identifier
        GetSavedTracks(citizenid, cb)
    else
        cb({})
    end
end)

RegisterNUICallback("deleteSong", function(data, cb)
    TriggerServerEvent('deleteSong', data)
end)
