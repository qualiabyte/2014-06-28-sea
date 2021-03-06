class ProcessingApp
    constructor: (sketch) ->
        @sketch = sketch
        @canvas = document.getElementById('pjs')
        @p5 = new Processing(@canvas, @sketch)

sketch = (p5) ->
    `with (p5) {`

    class Kamera
        constructor: ->
            @eye = new PVector(200, 200, 200)
            @target = new PVector(0, 0, 0)
            @up = new PVector(0, 0, -1)
            @offset = new PVector(200, 200, 200)
            @distance = 300
            @theta = -PI/4
            @phi = PI/3

        view: (eye=@eye, target=@target, up=@up) ->
            camera(
                eye.x,     eye.y,     eye.z,
                target.x,  target.y,  target.z,
                up.x,      up.y,      up.z
            )

        update: (dt) ->
            d = @distance
            @theta = cycles / 30
            @eye.set(
                d * cos(@theta) * sin(@phi),
                d * sin(@theta) * sin(@phi),
                d * cos(@phi)
            )
            @view @eye, @target, @up

    class Sea
        constructor: (@options) ->
            @radius = @options?.radius or 1000
            @level = @options?.level or 0

        draw: ->
            r = @radius
            fill(128, 64, 128, 128)
            beginShape()
            vertex(-r, -r, 0)
            vertex(+r, -r, 0)
            vertex(+r, +r, 0)
            vertex(-r, +r, 0)
            endShape()

        update: ->
            @level = 5*sin(cycles/2) + 30*cos(cycles/30)

    class Scene
        constructor: () ->
            @player = new Player()
            @sea = new Sea()
            @kamera = new Kamera()
            @kamera.target = @player.pos
            @lastUpdate = 0

        draw: ->
            @player.draw()
            @sea.draw()

        update: ->
            t = millis() / 1000
            dt = t - @lastUpdate
            @sea.update(dt)
            @player.update(dt)
            @kamera.update(dt)
            @lastUpdate = millis() / 1000

    class Player
        constructor: () ->
            @height = 100
            @pos = new PVector(0,0,400)
            @vel = new PVector(0,0,0)

        drawDiamond: () ->
            pushMatrix()
            translate @pos.x, @pos.y, @pos.z
            rotate cycles/2, 0, 0, 1
            rotate TAU/6.5, 1, -1, 0
            box 100
            popMatrix()

        draw: () ->
            fill 0, 0, 255
            pushMatrix()
            @drawDiamond()
            popMatrix()
            pushMatrix()
            rotate TAU/8, 0, 0, 1
            @drawDiamond()
            popMatrix()

        update: (dt) ->
            b = 0.5
            gravity = -150
            bouyancy = 180
            waterlevel = scene.sea.level
            waterline = 0
            if @pos.z > waterline + waterlevel
                @vel.z += gravity * dt
            else
                submerged = Math.max(waterlevel - (waterline + @pos.z), @height) / @height
                floatation = submerged * bouyancy
                resistance = b * @vel.z
                @vel.z += (gravity + floatation - resistance) * dt
            @pos.add(PVector.mult(@vel, dt))

    scene = new Scene()
    setup = () ->
        size 600, 400, P3D

    draw = () ->
        window.cycles = TAU * 0.001 * millis()
        colorMode(HSB)
        directionalLight (cycles/0.2 % 255), 20, 230, 0, 0, -1
        background (cycles % 255), 128, 255
        noStroke()
        scene.update()
        scene.draw()
    `}`

app = new ProcessingApp(sketch)
