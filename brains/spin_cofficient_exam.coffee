#
# Spin係数テスト用ロボット
#
# Note:
#   otameshi_plain_0.txt コースを使用すること
#
# Result:
#   y = 4.4447693889 * x^{-2.0253701142}
#
#   y - Handle Max
#   x - Velocity
#
brainbase = require './brainbase'


exports.Brain = class SpinCofficientExamBrain extends brainbase.BrainBase

    constructor: ->
        super()
        @logged = false
        @handle = 10

    consider: (status, time, player_info_list) ->
        method = accele: 0, handle: 0, help: false, retire: 0
        switch status.status
            when 'OK'
                @logged = false
                method.accele=10        # fullspeed
                method.handle=@handle
            when 'SPIN'
                if not @logged
                    console.log "Handle: #{@handle}, Velocity: #{@body.velocity}"
                    @handle += 10
                    if @handle > 60
                        method.retire = true
                    @logged = true
        return method
            
