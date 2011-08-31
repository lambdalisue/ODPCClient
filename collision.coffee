#!coffee
#
# required
# - vector.coffee - gist: 1177722
#
vector = require './vector'

collisionWithSectorAndPoint = (sector, point) ->
    # Collision detection of circular sector and point
    toRadian = (d) -> d * Math.PI / 180
    # Ready to calculate
    r = sector.r
    r2 = Math.pow r, 2
    theta = toRadian sector.theta
    heading = toRadian sector.heading
    # Create vector
    v1 = new vector.Vector [
        sector.x + r * Math.cos(heading + theta/2),
        sector.y + r * Math.sin(heading + theta/2)
    ]
    v2 = new vector.Vector [
        sector.x + r * Math.cos(heading - theta/2),
        sector.y + r * Math.sin(heading - theta/2)
    ]
    p = new vector.Vector [
        point.x - sector.x,
        point.y - sector.y
    ]
    # Collision conditions
    c1 = v1.cross(p) <= 0    # p is on right side of v1
    c2 = v2.cross(p) >= 0    # p is on left side of v2
    c3 = p.square() <= r2     # |p| <= r

    return c1 and c2 and c3

collisionWithSectorAndGrid = (sector, grid) ->
    # Collision detection of circular sector and grid
    toRadian = (d) -> d * Math.PI / 180
    # Ready to calculate
    r = sector.r
    r2 = Math.pow r, 2
    theta = toRadian sector.theta
    heading = toRadian sector.heading
    # Create vector
    v1 = new vector.Vector [
        r * Math.cos(heading + theta/2),
        r * Math.sin(heading + theta/2)
    ]
    v2 = new vector.Vector [
        r * Math.cos(heading - theta/2),
        r * Math.sin(heading - theta/2)
    ]
    # Create outer triangle for finding outer rectangle
    numerator = r2
    denominator = 2 * (r2 + v1.dot(v2))
    denominator = Math.sqrt denominator
    t = numerator / denominator
    tv1 = v1.multiple t
    tv2 = v2.multiple t
    # Find outer rectangle
    x1 = Math.min tv1.x, tv2.x, 0
    y1 = Math.min tv1.y, tv2.y, 0
    x2 = Math.max tv1.x, tv2.x, 0
    y2 = Math.max tv1.y, tv2.y, 0


    # Collision conditions
    c1 = v1.cross(p) <= 0    # p is on right side of v1
    c2 = v2.cross(p) >= 0    # p is on left side of v2
    c3 = p.square() <= r2     # |p| <= r

    return c1 and c2 and c3


unittest = ->
    assert = (condition, message) ->
        console.log message if not condition
    sector =
        x: 0, y: 0
        r: 10, theta: 45, heading: 90
    p1 = x: 0, y: 5
    p2 = x: 5, y: 0
    p3 = x: -5, y: 0

    assert isCollided(sector, p1), "sector and p1 is supposed to be collided"
    assert not isCollided(sector, p2), "sector and p2 is not supposed to be collided"
    assert not isCollided(sector, p3), "sector and p3 is not supposed to be collided"
unittest()
