fs = require 'fs'
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

exports.loadImage = loadImage = (filename) ->
    # DO NOT OPEN big file with this
    buffer = fs.readFileSync(filename)
    binary = []
    for code in buffer
        hex = Number(code).toString(16)
        hex = "0#{hex}" if hex.length is 1
        binary.push hex
    binary = binary.join("")
    return binary

