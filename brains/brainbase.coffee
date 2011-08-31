utils = require '../utils'
vector = require '../vector'

exports.Body = class Body extends utils.AccessorPropertyObject
    @SUSPEND_THRESHOLD = 50
    constructor: ->
        @x = @y = @velocity = @heading = 0
        @status = 'OK'
        @suspendCounter = 0

    @get 'x', -> @x_
    @set 'x', (value) ->
        @px = @x
        @x_ = value
    @get 'y', -> @y_
    @set 'y', (value) ->
        @py = @y
        @y_ = value

    isSuspend: ->
        return @suspendCounter > Body.SUSPEND_THRESHOLD
    resume: ->
        @suspendCounter = 0
    update: (status, time, player_info) ->
        @status = status
        if time > 0
            # Suspend check
            dx = parseInt(Math.abs(@px - @x) * 10)
            dy = parseInt(Math.abs(@py - @y) * 10)
            if dx is 0 and dy is 0
                @suspendCounter++
            else
                @suspendCounter = 0
        # Update location status
        @x = parseFloat(player_info.x)
        @y = parseFloat(player_info.y)
        @velocity = parseFloat(player_info.v)
        @heading = parseFloat(player_info.heading)

exports.defaultRiskProfile = defaultRiskProfile =
    outzone: 50
    road: 0
    dirt: 40
    wall: 50
    softwall: 50
    startline: 0
    startdirt: 20
    dashboard: 2
    jumpboard: 2

exports.BrainBase = class BrainBase extends utils.AccessorPropertyObject

    @LOOK_EXTENT = 12
    @LOOK_DISTANCE = 15
    @SEARCH_OFFSET = 4
    @SEARCH_THRESHOLD = 4
    @ACCELERATOR_MIN = -5
    @ACCELERATOR_MAX = 10
    @HANDLE_MIN = 0
    @HANDLE_MAX = 60

    constructor: (@riskProfile=null) ->
        @body_ = new Body
        @riskProfile ?= defaultRiskProfile

    # Readonly accesser properties
    @get 'map', -> @map_
    @get 'body', -> @body_

    wakeup: (@map_) ->

    run: (status, time, player_info_list) ->
        # Update body
        @body.update status, time, player_info_list.me
        
        if time < 0
            command = @createCommand 0, 0
        else
            command = @consider status, time, player_info_list
        return command
        
    createCommand: (accelerator=0, handle=0, help=false, retire=false) ->
        # Accelerator check
        if accelerator > 0
            accelerator = BrainBase.ACCELERATOR_MIN if accelerator < BrainBase.ACCELERATOR_MIN
            accelerator = BrainBase.ACCELERATOR_MAX if accelerator > BrainBase.ACCELERATOR_MAX
        if handle > 0
            # Handle check
            handleMax = @calcHandleMax()
            if Math.abs handle > handleMax
                handle = handle / Math.abs(handle) * handleMax
        command =
            accelerator: accelerator
            handle: handle
            help: help
            retire: retire
        return command

    calcHandleMax: ->
        # y = 4.4447693889 * x^{-2.0253701142}
        m = 4.4447693889
        n = -2.0253701142
        if @body.velocity is 0
            return 0
        max = m * Math.pow @body.velocity, n
        max = BrainBase.HANDLE_MAX if max > BrainBase.HANDLE_MAX
        max = BrainBase.HANDLE_MIN if not max?
        return max
