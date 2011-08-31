#!coffee
net = require 'net'
events = require 'events'
parser = require './parser'
utils = require './utils'
# Brains
brain_observer = require './brains/observer'
brain_spin_cofficient_exam = require './brains/spin_cofficient_exam'
brain_handle_cofficient_exam = require './brains/handle_cofficient_exam'

host = "192.168.1.28"
port = 17676
id = 100
name = "lambdalisue"
image = "./images/profile.png"

class Client extends events.EventEmitter
    constructor: (@id, @name, @image, @debug=false) ->
        @chunks = []

    connect: (host, port) =>
        @connection = net.createConnection port, host
        @connection.setEncoding 'utf8'
        # Add event lisners
        @connection.on 'connect', ->
            console.log "Opend connection to #{host}:#{port}"
        @connection.on 'end', ->
            console.log "Connection closed"
        @connection.on 'data', @recive_chunk
        @.once 'recived', (data) =>
            # Send initialize request
            img = utils.loadImage @image
            @send "Id=#{@id} Name=#{@name} Image=#{img}"
            @emit 'initialized'

    recive_chunk: (data) =>
        @chunks.push data
        if "\n" in data
            data = @chunks.join("")
            console.log "< #{@translate data}" if @debug
            @emit 'recived', data
            @chunks = []

    send: (data) =>
        data = "#{data} \n"
        console.log "> #{@translate data}" if @debug
        @connection.write "#{data}"

    translate: (str) ->
        return str.replace("\n", "\\n")

class Controller
    constructor: (@client, @brain) ->
        @map = null
        @player_list = null

    connect: (host, port) =>
        @client.on 'initialized', =>
            @client.once 'recived', @recievedCallbackOnce
        @client.connect host, port

    recievedCallbackOnce: (data) =>
        [status, time, player_info_list, @map, @player_list] = parser.parse data
        # Remove own entry
        delete @player_list[@client.id]
        # Add event listner
        @client.on 'recived', (data) =>
            @recievedCallback data
        # wakeup brain
        @brain.wakeup @map
        # run
        @run status, time, player_info_list
    recievedCallback: (data) =>
        [status, time, player_info_list] = parser.parse data, @player_list
        @run status, time, player_info_list

    run: (status, time, player_info_list) =>
        command = @brain.run status, time, player_info_list
        
        if command.help
            @client.send "Accel=0 Handle=0 help"
        else if command.retire
            @client.send "Accel=0 Handle=0 retire"
        else
            @client.send "Accel=#{command.accelerator} Handle=#{command.handle}"
            
client = new Client id, name, image, false
#brain = new brain_observer.Observer brain_observer.defaultRiskProfile
brain = new brain_handle_cofficient_exam.Brain
controller = new Controller client, brain
controller.connect host, port
