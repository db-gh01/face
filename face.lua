_addon.version = '1.0'
_addon.name = 'face'
_addon.command = 'face'
_addon.author = 'DB'

require('logger')

automode = false

function face(arg)

    -- 引数が指定されていたらそれをtid（ターゲットのID）とみなしてそのIDをターゲットにする
    -- 指定されていなければ自分の<t>をターゲットとする
    local target_info = nil
    if arg then
        local id = tonumber(arg)
        if id then
            target_info = windower.ffxi.get_mob_by_id(id)
        end
    else
        target_info = windower.ffxi.get_mob_by_target('t')
    end
    if not target_info then return end

    local player_info = windower.ffxi.get_mob_by_target('me')

    -- ターゲットの方向を取得
    local dx = target_info.x - player_info.x
    local dy = target_info.y - player_info.y
    local rad = - math.atan2(dy, dx)

    -- ターゲットの方向と自分の向いている角度が30°以上ずれていたら自分の向きを変える
    local delta = math.abs(rad - player_info.facing)
    if delta > (math.pi / 6) then
        windower.ffxi.turn(rad)
    end
end

windower.register_event('target change', function(index)
    if not automode then return end
    if index and index ~= windower.ffxi.get_player().index then
        local mob = windower.ffxi.get_mob_by_index(index)
        if not mob then return end
        face(mob.id)
    end
end)

windower.register_event('addon command', function (...)
    local args = {...}
    if args[1] and args[1]:lower() == 'auto' then
        if args[2] and args[2]:lower() == 'on' then
            automode = true
        elseif args[2] and args[2]:lower() == 'off' then
            automode = false
        end
        log(string.format("automode = %s", automode and "on" or "off"))
    else
        face(args[1])
    end
end)
