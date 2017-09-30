const FRAMES_PER_SECOND = 30
const PLANE_COUNT = 250

const MAX_UP_ACCELERATION = 1 * FRAMES_PER_SECOND
const MAX_DOWN_ACCELERATION = 2 * FRAMES_PER_SECOND
const MAX_SIDE_ACCELERATION = 2 * FRAMES_PER_SECOND
const MAX_VERT_SPEED = 4 * FRAMES_PER_SECOND
const MAX_SIDE_SPEED = 2 * FRAMES_PER_SECOND
const GROUND_BUFFER = 400

# Predicts result of one second of acceleration and movement on scalar
predict-one = (x, dx, dx2, max) ->
  if max >= Math.abs dx + dx2
    x + dx + dx2 * 0.5
  else
    x + (Math.sign dx) * max - 0.5 * dx * (max - dx) / dx2

lim-abs = (x, max) ->
  if max >= Math.abs x
    x
  else
    max * Math.sign x

# Predicts result of one second of acceleration and movement on vectors
predict = (pos, vel, acc) ->
  [(new THREE.Vector3 (predict-one pos.x, vel.x, acc.x, MAX_SIDE_SPEED),
      (predict-one pos.y, vel.y, acc.y, MAX_VERT_SPEED),
      (predict-one pos.z, vel.z, acc.z, 1000)),
   (new THREE.Vector3 (lim-abs vel.x + acc.x, MAX_SIDE_SPEED),
      (lim-abs vel.y + acc.y, MAX_VERT_SPEED),
      vel.z)]

class Plane
  (pos, vel) ->
    @pos = pos
    @vel = vel
    @acc = null # first acceleration

  do-step: ->
    ax = [-2, -1, 0, 1, 2][Math.floor Math.random! * 5] * FRAMES_PER_SECOND
    ay = [-2, -1, 0, 1, 2][Math.floor Math.random! * 4] * FRAMES_PER_SECOND
    acc = new THREE.Vector3 ax, ay, 0
    if @acc == null
      @acc = acc

    prediction = predict @pos, @vel, acc
    @pos = prediction[0]
    @vel = prediction[1]

export class Pilot
  (terrain-gen, camera) ->
    @terrain-gen = terrain-gen
    @camera = camera
    @vel = new THREE.Vector3 0, 0, -20 * FRAMES_PER_SECOND
    @acc = new THREE.Vector3 0, 0, 0
    @ticks = 0
    @planes = []

  tick: ->
    if @ticks == 0
      if @planes.length > 0
        best-plane = @planes[Math.floor Math.random! * @planes.length]
        @acc = best-plane.acc

      # Predict location, velocity after current second
      prediction = predict @camera.position, @vel, @acc

      # Create new planes
      @planes = []
      for i til PLANE_COUNT
        @planes.push new Plane prediction[0], prediction[1]

    # Update planes
    for plane in @planes
      plane.do-step!

    # Kill dead planes
    @planes = @planes.filter (plane) ~>
      plane.pos.y >= GROUND_BUFFER + @terrain-gen.get-y plane.pos.x, plane.pos.z
    # Spawn new planes by copying random existing planes
    for i from @planes.length + 1 til PLANE_COUNT
      to-copy = @planes[Math.floor Math.random! * (i - 1)]
      new-plane = new Plane to-copy.pos, to-copy.vel
      new-plane.acc = to-copy.acc
      @planes.push new-plane

    @vel.x += @acc.x * 1.0 / FRAMES_PER_SECOND
    @vel.y += @acc.y * 1.0 / FRAMES_PER_SECOND
    if MAX_SIDE_SPEED < Math.abs @vel.x
      @vel.x = MAX_SIDE_SPEED * Math.sign @vel.x
    if MAX_VERT_SPEED < Math.abs @vel.y
      @vel.y = MAX_VERT_SPEED * Math.sign @vel.y

    @camera.position.x += @vel.x / FRAMES_PER_SECOND
    @camera.position.y += @vel.y / FRAMES_PER_SECOND
    @camera.position.z += @vel.z / FRAMES_PER_SECOND

    @ticks += 1
    @ticks %= FRAMES_PER_SECOND
