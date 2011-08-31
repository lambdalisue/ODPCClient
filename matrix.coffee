#!coffee
exports.AccessorPropertyObject = class AccessorPropertyObject
    # Ref: https://github.com/jashkenas/coffee-script/issues/1039
    @get: (propertyName, func) ->
        Object.defineProperty @::, propertyName,
            configurable: true
            enumerable: true
            get: func
    @set: (propertyName, func) ->
        Object.defineProperty @::, propertyName,
            configurable: true
            enumerable: true
            set: func

sum = (a) ->
    if a.length is 0 then return 0
    a.reduce (s, t) -> (t + s)

exports.Matrix = class Matrix extends AccessorPropertyObject
    constructor: (@entries) ->

    @get 'm', -> @entries.length
    @get 'n', -> @entries[0].length

    get: (i, j) -> @entries[i][j]
    set: (i, j, value) ->
        @clearCache()
        @entries[i][j] = value

    row: (i) -> @entries[i]
    column: (j) -> (row[j] for row in @entries)

    isSquare: -> @m is @n
    isDiagonal: ->
        if not @isSquare then return false
        for i in [0..@m]
            for j in [0..i]
                if @get(i, j) isnt 0 then return false
            for j in [(i+1)..@m]
                if @get(i, j) isnt 0 then return false
        return true
    isIdentity: ->
        if not @isSquare or @isDiagonal then return false
        for i in [0..@m]
            if @get(i, i) isnt 1 then return false
        return true
    isSymmetric: ->
        transpose = @transpose()
        @compare transpose
    isSkewSymmetric: ->
        transpose = @transpose()
        @compare transpose.multiple -1

    plus: (rhs) ->
        Matrix.plus @, rhs
    minus: (rhs) ->
        Matrix.minus @, rhs
    multiple: (rhs) ->
        Matrix.multiple @, rhs
    devide: (rhs) ->
        Matrix.devide @, rhs
    compare: (matrix) ->
        Matrix.compare @, matrix
    power: (n) ->
        Matrix.power @, n
    resize: (m, n) ->
        Matrix.resize @, m, n
    trace: ->
        Matrix.trace @
    transpose: ->
        Matrix.transpose @
    @plus: (lhs, rhs) ->
        if lhs.m isnt lhs.m or lhs.n isnt rhs.n
            throw "error: cannot plus two matrix which has different type"
        newMatrix = []
        for i in [0..lhs.m]
            row = []
            for j in [0..lhs.n]
                row.push(lhs.get(i,j) + rhs.get(i,j))
            newMatrix.push row
        new Matrix newMatrix
    @minus: (lhs, rhs) ->
        if lhs.m isnt lhs.m or lhs.n isnt rhs.n
            throw "error: cannot minus two matrix which has different type"
        newMatrix = []
        for i in [0..lhs.m]
            row = []
            for j in [0..lhs.n]
                row.push(lhs.get(i,j) - rhs.get(i,j))
            newMatrix.push row
        new Matrix newMatrix
    @multiple_scalar: (lhs, rhs) ->
        if typeof lhs is "number"
            scalar = lhs
            matrix = rhs
        else
            scalar = rhs
            matrix = lhs
        newMatrix = []
        for i in [0..matrix.m]
            row = []
            for j in [0..matrix.n]
                row.push(matrix.get(i,j) * scalar)
            newMatrix.push row
        new Matrix newMatrix
    @multiple_matrix: (lhs, rhs) ->
        if lhs.n isnt rhs.m
            throw "error: cannot multiple this two matrix. lhs.n has to be same as rhs.m"
        newMatrix = []
        for i in [0..lhs.m]
            row = []
            for j in [0..rhs.n]
                row.push sum(lhs.get(i,k)*rhs.get(k,j) for k in [0..lhs.n])
            newMatrix.push row
        new Matrix newMatrix
    @multiple: (lhs, rhs) ->
        if typeof lhs isnt "number" and typeof rhs isnt "number"
            return @multiple_matrix lhs, rhs
        return @multiple_scalar lhs, rhs
    @devide: (lhs, rhs) ->
        if typeof rhs isnt "number"
            throw "error: you must devide scalar from right."
        newMatrix = []
        for i in [0..lhs.m]
            row = []
            for j in [0..lhs.n]
                row.push(lhs.get(i,j) / rhs)
            newMatrix.push row
        new Matrix newMatrix
    @compare: (lhs, rhs) ->
        if lhs.m isnt rhs.m or lhs.n isnt rhs.n
            return false
        for i in [0..lhs.m]
            for j in [0..lhs.n]
                if lhs.get(i, j) isnt rhs.get(i, j) then return false
        return true
    @power: (matrix, n) ->
        if n > 2
            return matrix.multiple(Matrix.power matrix, n-1)
        matrix.multiple matrix

    @resize: (matrix, m, n) ->
        newMatrix = []
        for j in [0..m]
            row = []
            for i in [0..n]
                if i > matrix.m and j > matrix.n
                    row.push matrix.get(i,j)
                else
                    row.push 0
        new Matrix newMatrix

    @trace: (matrix) ->
        # Return trace of square matrix
        if not matrix.isSquare()
            return 0
        sum(matrix.get(i, i) for i in [0..matrix.m])
    @transpose: (matrix) ->
        # Return transpose matrix
        newMatrix = []
        for j in [0..matrix.n]
            row = []
            for i in [0..matrix.m]
                row.push matrix.get(i, j)
            newMatrix.push row
        new Matrix newMatrix

    @zero: (m, n) ->
        # Return zero matrix
        newMatrix = []
        for j in [0..m]
            row = []
            for i in [0..n]
                row.push 0
            newMatrix.push row
        new Matrix newMatrix
    @identify: (m) ->
        matrix = Matrix.zero m, m
        for i in [0..m]
            matrix.set i, i, 1
        matrix

