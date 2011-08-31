brainbase = require './brainbase'


exports.Observer = class Observer extends brainbase.BrainBase

    constructor: ->
        @handle = 0
        @accele = 0
        @handleAcceleration = 0
        @acceleAcceleration = 0

    @RISK_THRESHOLD = 5
    @SPEEDLOOK_DISTANCE = 20
    @SPEEDRISK_THRESHOLD = 10

    consider: (status, time, player_info_list) ->
        switch status.status
            when 'OK', 'DIRT', 'DASH'

                # Get total risk and chips in a field of vision
                [totalRisk, visibleChips] = @lookAt @body.heading, Observer.LOOK_EXTENT, Observer.LOOK_DISTANCE
                
                if totalRisk > Observer.RISK_THRESHOLD
                    way = @searchWay @body.heading, Observer.SEARCH_OFFSET, Observer.SEARCH_THRESHOLD
                else
                    way = @straightWay @body.heading

                # Get total risk and chips in a field of vision
                [totalRisk, visibleChips] = @lookAt @body.heading, Observer.LOOK_EXTENT, Observer.FIRSTLOOK_DISTANCE
                if totalRisk > Observer.SPEEDRISK_THRESHOLD
                    method.accele = 5

            when 'OUT', 'SPIN', 'JUMP', 'CLASH'
                # Do nothing
                method = @controll null
            else
                throw "error: unknown status has passed"
        return method

    getStraightWay: (heading=null) ->
        heading ?= @body.heading
        return {
            heading: heading
            diff: 0
            best: true
        }
    searchLowRiskWay: (sightProfile, heading=null) ->
        heading ?= @body.heading
        prefer = null
        for diff in [offset..60] by offset
            lhs = heading: heading+diff, diff: diff
            rhs = heading: heading-diff, diff: -diff
            lhs.risk = @getTotalRiskInSight sightProfile, lhs.heading
            rhs.risk = @getTotalRiskInSight sightProfile, rhs.heading
            min = if lhs.risk < rhs.risk then lhs else rhs

            if min.risk < threshold
                min.best = true
                return min
            else if not prefer? or prefer.risk > min.risk
                prefer = min
        # Could not found best way so use prefer
        prefer.best = false
        return prefer
    getRiskAt: (x, y) ->
        translateToRisk = (type) =>
            switch type
                when 0 then return @riskProfile.outzone
                when 1 then return @riskProfile.road
                when 2 then return @riskProfile.dirt
                when 3 then return @riskProfile.wall
                when 4 then return @riskProfile.softwall
                when 5 then return @riskProfile.startline
                when 6 then return @riskProfile.startdirt
                when 7 then return @riskProfile.dashboard
                when 8 then return @riskProfile.jumpboard
                else
                    throw "error: unknown map type has passed (#{type})"
        type = @map.get x, y
        return translateToRisk type

    getTotalRiskInSight: (sightProfile, heading=null) ->
        chips = @getChipsInSight sightProfile, heading
        risks = []
        for chip in chips
            risks.push @getRiskAt chip.x, chip.y
        if risks.length > 0
            totalRisk = risks.reduce (t, s) -> t + s
            totalRisk = totalRisk / risks.length
        else
            totalRisk = @riskProfile.outzone
        return totalRisk

    getChipsInSight: (sightProfile, heading=null) ->
        heading ?= @body.heading
        [[v1, v2], [x1, y1, x2, y2]] = 
            createCircularSectorSight heading, sightProfile.theta, sightProfile.radius
        chips = []
        r2 = Math.pow sightProfile.radius, 2
        for y in [y1..y2]
            for x in [x1..x2]
                # Collision detection
                p = new vector.Vector [x, y]
                c1 = v1.cross p <= 0
                c2 = v2.cross p >= 0
                c3 = p.square() <= r2
                if c1 and c2 and c3
                    chipX = parseInt(@body.x + x)
                    chipY = parseInt(@body.y + y)
                    chips.push x: chipX, y: chipY
        return chips
                        
createCircularSectorSight = (heading, theta, radius) ->
    # Create visual sight formed circular sector with theta (degree) and 
    # radius. the returning circular sector is an vector list which is 
    # inclined at heading degrees
    #
    # Return: [
    #   [v1, v2],           - two vector of both side of circular sector 
    #   [x1, y1, x2, y2]    - points of outer rectangle
    # ]
    toRadian = (d) ->
        return d * Math.PI / 180
    # Convert degree to radian
    heading = toRadian heading
    theta = toRadian theta
    # Create vector of both side
    v1 = new vector.Vector [
        radius * Math.cos(heading+theta),
        radius * Math.sin(heading+theta)
    ]
    v2 = new vector.Vector [
        radius * Math.cos(heading-theta),
        radius * Math.sin(heading-theta)
    ]
    # Calculate outer triangle
    r2 = Math.pow distance, 2
    denominator = 2 * (r2 + v1.dot v2)
    denominator = Math.sqrt denominator
    t = r2 / denominator
    # Create vector of outer triangle for finding outer rectangle
    vt1 = v1.multiple(t)
    vt2 = v2.multiple(t)
    # Find outer rectangle via outer triangle
    x1 = Math.min vt1.x, vt2.x, 0
    y1 = Math.min vt1.y, vt2.y, 0
    x2 = Math.max vt1.x, vt2.x, 0
    y2 = Math.max vt1.y, vt2.y, 0
    return [
        [v1, v2],
        [x1, y1, x2, y2]
    ]
