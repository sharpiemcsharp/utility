function hexColorEntering(letter)
    local fn = function(player, down, x, y)
        if ranks[player.name] >= RANKS.ROOM_ADMIN and down and player.draw.enteringColor then
            _S.draw.addHexCharToColor(player, letter)
        end
    end
    return fn
end

function highscore()
    local hiscore = { 0 }
    for name, player in pairs(tfm.get.room.playerList) do
        if player.score >= hiscore[1] then
            hiscore = { player.score, name }
        end
    end
    return hiscore[2]
end

function hearts(player)
    local width = 16
    for i = 1, #hearts do
        tfm.exec.removeImage(hearts[i])
    end
    player.hearts = {}
    if player.hearts then
        local s = #player.hearts.count * (width + 3)
        for i = 1, #player.hearts do
            table.insert(
                player.hearts,
                tfm.exec.addImage(
                    "ndStXBw.png",
                    "$" .. player.name,
                    -(s / 2) + (i * (width + 3)) - ((width / 2) * i),
                    -50
                )
            )
        end
    end
end

function translate(str, lang)
    lang = lang or "en"
    return translations[lang] and translations[lang][str] or translations["en"][str] or str or "Error"
end

function tfm.exec.chatMessagePublic(str, players, ...)
    local arg = { ... }
    if arg and arg[1] then
        for n, p in pairs(players) do
            tfm.exec.chatMessage(translate(str, p.lang):format(...), p.name)
        end
    else
        for n, p in pairs(players) do
            tfm.exec.chatMessage(translate(str, p.lang), p.name)
        end
    end
end

function getColor(color)
    if color and color:sub(1, 1) == "#" then
        color = color:sub(2)
    end
    if color and tonumber(color, 16) then
        color = tonumber(color, 16)
        if color == 0 then
            color = 1
        end
        return color
    elseif color and _S.draw.colors[color:lower()] then
        return _S.draw.colors[color:lower()].color
    end
end

function sortScores()
    local tbl = {}
    for k, v in pairs(tfm.get.room.playerList) do
        table.insert(tbl, { name = v.playerName, score = v.score })
    end
    table.sort(tbl, function(i, v)
        return i.score > v.score
    end)
    return tbl
end

function playersAlive()
    local i = 0
    for n, p in pairs(tfm.get.room.playerList) do
        if not p.isDead then
            i = i + 1
        end
    end
    return i
end

function isTribeRoom()
    return string.byte(tfm.get.room.name, 2) == 3
end

function shouldBeAdmin(player)
    if player.hashTag == "0001" or player.hashTag == "0010" or player.hashTag == "0015" or player.hashTag == "0020" then
        DEBUG("shouldBeAdmin(%s): true (staff tag)", player.name)
        return true
    end

    local roomName = getInternalRoomName()
    DEBUG("shouldBeAdmin(%s): roomName:%s", player.name, roomName)

    if player.tribeName then
        DEBUG("shouldBeAdmin(%s): player.tribeName:%s", player.name, player.tribeName)
        if isTribeRoom() then
            if roomName:lower() == player.tribeName:lower() then
                return true
            end
        else
            -- TODO first do some checks that roomName isn't a player ?
            if roomName:lower() == player.tribeName:lower() then
                return true
            end
        end
    end

    if roomName:lower() == player.name:lower() then
        DEBUG("shouldBeAdmin(%s): true (name matched)", player.name)
        return true
    end

    if getHashTag(player.name) == "0000" and roomName:lower() == getNameWithoutHashTag(player.name):lower() then
        DEBUG("shouldBeAdmin(%s): true (name matched without #0000 tag)", player.name)
        return true
    end

    DEBUG("shouldBeAdmin(%s): false", player.name)
    return false
end

function getInternalRoomName()
    local roomName = tfm.get.room.name

    if isTribeRoom() then
        return roomName:sub(2)
    end

    if roomName:sub(1, 2) == "e2" then
        -- Remove e2 community prefix otherwise it interferes with matching below
        roomName = tfm.get.room.name:sub(3)
    end

    return roomName:match("%d+(.+)$")
end

function getHashTag(name)
    local hashTag = name:match("#(.*)")

    if hashTag == nil then
        return "0000"
    end

    return tag
end

function getNameWithoutHashTag(name)
    local nameWithoutHashTag = name:match("(.*)#")

    if nameWithoutHashTag == nil then
        return name
    end

    return nameWithoutHashTag
end
