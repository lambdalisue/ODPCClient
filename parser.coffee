exports.Map = class Map
    constructor: (data) ->
        re = new RegExp '^([0-9]+):([0-9]):([0-9]+):([0-9]+):([0-9]+)::(([0-9]x[0-9]+:)+):$'
        data.match re
        @size = parseInt RegExp.$1
        @laps = parseInt RegExp.$2
        @viewAngle = parseInt RegExp.$3
        @forwardView = parseInt RegExp.$4
        @rearView = parseInt RegExp.$5
        # Expand chip infos
        _chips = []
        for e in RegExp.$6.split(":")
            [type, n] = e.split("x")
            for i in [0..n-1]
                _chips.push parseInt type
        # Translate linear chip info to 2D chip info
        @chips = []
        for y in [0..@size-1]
            row = []
            for x in [0..@size-1]
                row.push _chips[y*@size+x]
            @chips.push row
        console.log "Map size: #{@size}x#{@size}"

    isBound: (x, y) ->
        if 0 <= x < @size and 0 <= y < @size
            return true
        return false

    get: (x, y) ->
        if @isBound x,y
            return @chips[y][x]
        return 0

    toString: ->
        translate = (t) ->
            switch t
                when 0 then return "/"      # Outzone
                when 1 then return " "      # Road
                when 2 then return "."      # Dirt
                when 3 then return "#"      # Wall
                when 4 then return "*"      # Softwall
                when 5 then return "="      # Startline
                when 6 then return "."      # Startline (dirt)
                when 7 then return "-"      # Dashboard
                when 8 then return "^"      # Jumpboard
        # Reverse map for easy displaying
        rows = []
        for y in [0..@size-1]
            row = ""
            for x in [0..@size-1]
                row += translate @chips[y][x]
            rows.unshift(row)
        data = rows.join("\n")
        str = """
            Size: #{@size}x#{@size}
            Laps: #{@laps}
            View angle: #{@viewAngle}
            Forward view: #{@forwardView}
            Rear view: #{@rearView}
            Data:
            #{data}
            """

exports.Status = class Status
    @OK:    "OK"
    @OUT:   "OUT"
    @SPIN:  "SPIN"
    @JUMP:  "JUMP"
    @DASH:  "DASH"
    @DIRT:  "DIRT"
    @CRASH: "CRASH"
    constructor: (s) ->
        @issue = s[0] is "-"
        @status = s[1..s.length]

exports.parse = parse = (response, player_list=null, debug=true) ->
    # parse response string
    response = response.split(" ")
    status = new Status response.shift()

    time = parseInt(response.shift().split("=")[1])

    # Convert response to dict obj
    infos = {}
    for e in response
        [key, value] = e.split("=")
        infos[key] = value

    if time is -50
        # Create player list
        player_list = (value for key, value of infos when key[0..2] is "id_")
        player_list.unshift "me"
        if debug?
            console.log "=== Player List ====================="
            console.log player_list.join "\n"
        # Create map
        map = new Map infos.map
        if debug?
            console.log "=== Map Infos ======================="
            console.log map.toString()
    else
        map = null

    # Create player info list
    player_info_list = {}
    for player_id in player_list
        player_info_list[player_id] =
            x: infos["#{player_id}.x"]
            y: infos["#{player_id}.y"]
            v: infos["#{player_id}.v"]
            heading: infos["#{player_id}.heading"]

    if time is -50
        return [status, time, player_info_list, map, player_list]
    else
        return [status, time, player_info_list]
