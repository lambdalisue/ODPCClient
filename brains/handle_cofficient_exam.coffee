#
# Handle係数テスト用ロボット
#
# Note:
#   otameshi_plain_0.txt コースを使用すること
#
brainbase = require './brainbase'


exports.Brain = class HandleCofficientExamBrain extends brainbase.BrainBase

    constructor: ->
        super()
        @handlePrevious = 0
        @headingPrevious = 90
        @velocityPrevious = 0

    consider: (status, time, player_info_list) ->
        switch status.status
            when 'OK'
                command = @createCommand HandleCofficientExamBrain.ACCELERATOR_MAX, HandleCofficientExamBrain.HANDLE_MAX
                # Logging
                dx = @body.px - @body.x
                dy = @body.py - @body.y
                dd = Math.sqrt Math.pow(dx, 2), Math.pow(dy, 2)
                rad = Math.atan dx, dy
                dec = rad * 180 / Math.PI
                theta = @headingPrevious - dec
                console.log "Handle: #{@handlePrevious} Velocity: #{@velocityPrevious} theta: #{theta}"
                # Update
                @handlePrevious = command.handle
                @headingPrevious = @body.heading
                @velocityPrevious = @body.velocity
            else
                command = @createCommand()
        return command
            
