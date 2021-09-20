local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end

BardAddon = BardAddon or {}
BardAddon.aio_clientLoaded = true
local MusicalHandlers = AIO.AddHandlers("MusicalHandlers", {})


function BardAddon.CallToPlayNearBardSong(songId)
	AIO.Handle("MusicalHandlers","CallToPlayNearBardSong", songId)

end

function BardAddon.StartPlayingSong(songId)
	AIO.Handle("MusicalHandlers","StartPlayingSong", songId)
end


function BardAddon.StopPlayingSong()
	AIO.Handle("MusicalHandlers","StopPlayingSong")
end

function MusicalHandlers.SelfUpdate(player,songId)
	SELF_BARD_SONG_ID = tonumber(songId)
	BardAddon.UpdateInterface()
end
function MusicalHandlers.AroundUpdate(player,id)
	BardAddon.nearSongs[tostring(id)] = true
	
end
function MusicalHandlers.SelfSongStop(player)
	SELF_BARD_SONG_ID = 0
	BardAddon.UpdateInterface()
end

