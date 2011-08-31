#!coffee
utils = require './utils'

exports.Vector = class Vector extends utils.AccessorPropertyObject
    constructor: (@axes) ->

    @get 'x', -> @axes[0] if @axes.length is 2 or @axes.length is 3
    @get 'y', -> @axes[1] if @axes.length is 2 or @axes.length is 3
    @get 'z', -> @axes[2] if @axes.length is 3
    @set 'x', (value) -> @axes[0] = value if @axes.length is 2 or @axes.length is 3
    @set 'y', (value) -> @axes[1] = value if @axes.length is 2 or @axes.length is 3
    @set 'z', (value) -> @axes[2] = value if @axes.length is 3

    # Instance methods
    #
    plus: (vector) ->
        return Vector.plus(@, vector)
    minus: (vector) ->
        return Vector.minus(@, vector)
    multiple: (scalar) ->
        return Vector.multiple(@, scalar)
    devide: (scalar) ->
        return Vector.devide(@, scalar)
    dot: (vector) ->
        return Vector.dot(@, vector)
    cross: (vector) ->
        return Vector.cross(@, vector)
    square: ->
        squareTotal = 0
        for axis in @axes
            squareTotal += Math.pow axis, 2
        return squareTotal
    size: ->
        return Math.sqrt @square()
    unit: ->
        return @devide @size()
    toString: ->
        if @axes.length is 2
            return "<Vector (#{@x}, #{@y})>"
        else if @axes.length is 3
            return "<Vector (#{@x}, #{@y}, #{@z})>"
        return "<Vector #{@axes.length} dimension>"

    # Class methods
    #
    @plus: (lhs, rhs) ->
        if lhs.axes.length is not rhs.axes.length
            throw "error: cannot plus two vector which has different dimension"
        newAxes = []
        for i in [0..lhs.axes.length]
            newAxes.push lhs.axes[i] + rhs.axes[i]
        return new Vector newAxes
    @minus: (lhs, rhs) ->
        if lhs.axes.length is not rhs.axes.length
            throw "error: cannot minus two vector which has different dimension"
        newAxes = []
        for i in [0..lhs.axes.length]
            newAxes.push lhs.axes[i] - rhs.axes[i]
        return new Vector newAxes
    @multiple: (lhs, rhs) ->
        if typeof lhs is not "number" and typeof rhs is not "number"
            throw "error: cannot multiple two vector, use scalar value for multiplication or dot or cross for vector multiplication"
        if typeof lhs is "number"
            scalar = lhs
            vector = rhs
        else
            scalar = rhs
            vector = lhs
        newAxes = []
        for axis in vector.axes
            newAxes.push axis * axis
        return new Vector newAxes
    @devide: (lhs, rhs) ->
        if typeof lhs is not "number" and typeof rhs is not "number"
            throw "error: cannot devide two vector, use scalar value for division"
        if typeof lhs is "number"
            scalar = lhs
            vector = rhs
        else
            scalar = rhs
            vector = lhs
        newAxes = []
        for axis in vector.axes
            newAxes.push axis / axis
        return new Vector newAxes
    @dot: (lhs, rhs) ->
        if lhs.axes.length is not rhs.axes.length
            throw "error: cannot dot product two vector which has different dimension"
        product = 0
        for i in [0..lhs.axes.length]
            product += lhs.axes[i]*rhs.axes[i]
        return product
    @cross: (lhs, rhs) ->
        if lhs.axes.length is not rhs.axes.length
            throw "error: cannot cross product two vector which has different dimension"
        if lhs.axes.length is 2
            return lhs.x*rhs.y-lhs.y*rhs.x
        else if lhs.axes.length is 3
            newX = lhs.y*rhs.z - lhs.z*rhs.y
            newY = lhs.z*rhs.x - lhs.x*rhs.z
            newZ = lhs.x*rhs.y - lhs.y*rhs.x
            return new Vector [newX, newY, newZ]

unittest = ->
    v2 = new Vector([1, 2])
    v3 = new Vector([1, 2, 3])
    v4 = new Vector([1, 2, 3, 4])
    console.log v2.toString()
    console.log " x: #{v2.x}, y: #{v2.y}, z: #{v2.z}"
    console.log v3.toString()
    console.log " x: #{v3.x}, y: #{v3.y}, z: #{v3.z}"
    console.log v4.toString()
    console.log " x: #{v4.x}, y: #{v4.y}, z: #{v4.z}"
#unittest()
