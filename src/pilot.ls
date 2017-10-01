const ZSPEED = 20
const ZCYCLE = 500.0 * ZSPEED
const XSCALE = 2000
const LAYERS = 1

class Path
  (z0, x0, dx0) ->
    @a = for i til LAYERS
      Math.random!
    @b = for i til LAYERS
      Math.random!
    @c = for i til LAYERS
      Math.random!
    @b = [1]

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

const MAX_UP_ACCEL = 0.05
const MAX_DOWN_ACCEL = 0.15
const BUFFER = 500

export class Pilot
  (terrain-gen, camera) ->
    @terrain-gen = terrain-gen
    @camera = camera

    @path = new Path -@camera.position.z, 0, 0

    @vy = 0

  can-follow-path: (z, y, vy, path) ->
    works = true
    for j til 1000 by 50
      loop-z = z + j * ZSPEED
      if y + vy * j + 0.5 * MAX_UP_ACCEL * j * j <= BUFFER + @terrain-gen.get-y (path.x loop-z), -loop-z
        return false
    return true

  tick: ->
    z = -@camera.position.z # Z used for paths is positive
    y = @camera.position.y

    new-path = new Path z, (@path.x z), @path.dx z
    # Score path by how low it keeps the camera over the next 100 ticks
    cur-score = 0
    new-score = 0
    for i til 1000
      trial-z = z + i * ZSPEED
      cur-score = Math.max cur-score, @terrain-gen.get-y (@path.x trial-z), trial-z
      new-score = Math.max new-score, @terrain-gen.get-y (new-path.x trial-z), trial-z
    if new-score < cur-score and @can-follow-path z, y, @vy, new-path
      @path = new-path

    working-accel = MAX_UP_ACCEL
    for test-accel from MAX_UP_ACCEL to -MAX_DOWN_ACCEL by -(MAX_DOWN_ACCEL + MAX_UP_ACCEL) / 4.0
      if test-accel >= working-accel
        continue
      next-z = z + ZSPEED
      next-y = y + @vy + 0.5 * test-accel
      next-vy = @vy + test-accel
      if @can-follow-path next-z, next-y, next-vy, @path
        working-accel = test-accel
      else
        break

    @camera.position.z -= ZSPEED
    @camera.position.x = @path.x -@camera.position.z
    @camera.position.y += @vy + 0.5 * working-accel
    @vy += working-accel
    ideal-rot-x = 0.5 * Math.atan2 @vy, ZSPEED
    @camera.rotation.x = 0.95 * @camera.rotation.x + 0.05 * ideal-rot-x
