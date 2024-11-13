ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('getSavedTracks', function(source, cb, citizenid)
    local selectQuery = "SELECT url FROM lb_music WHERE citizenID = @citizenid"
    local selectParams = { ['@citizenid'] = citizenid }
    
    MySQL.Async.fetchAll(selectQuery, selectParams, function(results)
        if results then
            cb(results)
        else
            cb({})
        end
    end)
end)

function SaveSongToPlaylist(citizenid, url)
    local insertQuery = "INSERT INTO lb_music (citizenID, url) VALUES (?, ?)"
    local insertParams = { citizenid, url }
    MySQL.query.await(insertQuery, insertParams)
end

function DeleteSongFromPlaylist(citizenid, trackId)
    local deleteQuery = "DELETE FROM lb_music WHERE citizenID = ? AND url = ?"
    local deleteParams = { citizenid, trackId }
    MySQL.query.await(deleteQuery, deleteParams)
end

RegisterNetEvent("phone:youtube_music:soundStatus")
AddEventHandler("phone:youtube_music:soundStatus", function(type, data)
    local src = source
    local musicId = "phone_youtubemusic_id_" .. src
    if type ~= "position" and type ~= "play" and type ~= "volume" and type ~= "stop" then 
        print("Invalid type for phone:youtube_music:soundStatus: " .. type)
    end

    TriggerClientEvent("phone:youtube_music:soundStatus", -1, type, musicId, data)
end)

RegisterNetEvent('saveSong')
AddEventHandler('saveSong', function(data)
    local youtubeUrl = data.url
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if xPlayer then
        local citizenid = xPlayer.identifier
        SaveSongToPlaylist(citizenid, youtubeUrl)
        TriggerClientEvent('notification', src, { type = 'success', title = 'Song saved successfully!' })
    else
        print("Player not found!")
    end
end)

RegisterNetEvent('deleteSong')
AddEventHandler('deleteSong', function(data)
    local src = source
    local trackId = data.trackId
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if xPlayer then
        local citizenid = xPlayer.identifier
        DeleteSongFromPlaylist(citizenid, trackId)
    end
end)
