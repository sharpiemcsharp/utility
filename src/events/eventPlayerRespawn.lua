function eventPlayerRespawn(name)
    local p = players[name]
    if p then
        p.facingRight = true
        p.lastSpawn   = os.time()
        -- Notify listeners
        notifyNameListeners(name, function(player, sn, s)
            local cb = s.callbacks.playerRespawn
            if cb then
                cb(player)
            end
        end)
    end
end
