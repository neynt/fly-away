const ZSPEED = 20
const ZCYCLE = 250.0 * ZSPEED
const XSCALE = 1000
const LAYERS = 10

class Path
  (z0, x0, dx0) ->
    @a = for i til LAYERS
      Math.random!
    @b = for i til LAYERS
      Math.random!
    @c = for i til LAYERS
      Math.random!

    @z0 = z0
    @x0 = 0
    @adj = 0
    @x0 = x0 - @x z0
    @adj = (dx0 - @dx z0) / XSCALE
    if 5 < Math.abs @adj
      @adj = 5 * Math.sign @adj

  x: (z) ->
    z = (z - @z0) / ZCYCLE
    x = 0
    for i til LAYERS
      x += @a[i] * Math.sin @b[i] * z + @c[i] * Math.PI * 2
    x += @adj / (z * z + 1) * Math.sin z
    x * XSCALE + @x0

  dx: (z) ->
    z = (z - @z0) / ZCYCLE
    x = 0
    for i til LAYERS
      x += @a[i] * @b[i] * Math.cos @b[i] * z + @c[i] * Math.PI * 2
    x += @adj / (z*z + 1)^2 * ((z*z + 1) * (Math.cos z) - 2 * z * Math.sin z)
    x * XSCALE + @x0

export class Pilot
  (terrain-gen, camera) ->
    @terrain-gen = terrain-gen
    @camera = camera

    @path = new Path -@camera.position.z, 0, 0

  tick: ->
    @camera.position.z -= ZSPEED
    z = -@camera.position.z # our Z is positive
    # Try a new path
    new-path = new Path z, (@path.x z), @path.dx z
    # Score path by how low it keeps the camera over the next 100 ticks
    cur-score = 0
    new-score = 0
    for i til 1000
      trial-z = z + i * ZSPEED
      cur-score += @terrain-gen.get-y (@path.x trial-z), trial-z
      new-score += @terrain-gen.get-y (new-path.x trial-z), trial-z
    if new-score < cur-score
      @path = new-path

    @camera.position.x = @path.x -@camera.position.z

    cur-y = @terrain-gen.get-y @camera.position.x, @camera.position.z
    nxt-y = @terrain-gen.get-y @camera.position.x, @camera.position.z - 1000
    dy = cur-y - nxt-y
    ideal-rot-x = -0.2*(Math.atan2(dy, 1000))
    @camera.rotation.x = 0.98 * @camera.rotation.x + 0.02 * ideal-rot-x
    @camera.position.y = 400 + cur-y
