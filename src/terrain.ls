window.perlin = perlin = require './perlin.ls'

CHUNK_SIZE = 256
SEED = Date.now!

# The buffer is split into CHUNK_SIZE×CHUNK_SIZE chunks.
# The buffer is indexed by (buffer_x, buffer_y).
# A chunk is indexed by (chunk_idx), where chunk_idx = chunk_x + chunk_y * CHUNK_SIZE.

export class Terrain
  ->
    @buffer = {}

  # Returns the chunk at the specified buffer coordinate.
  # Creates it if it doesn't exist.
  # buffer_x, buffer_y: Integer indices into the buffer.
  get-chunk: (buffer_x, buffer_y) ->
    X = buffer_x
    Y = buffer_y
    if not @buffer[X]
      @buffer[X] = {}
    if not @buffer[X][Y]
      @buffer[X][Y] = new Float32Array CHUNK_SIZE * CHUNK_SIZE
        ..fill -1
    @buffer[X][Y]

  # Public. Call this thing from outside.
  # x, y: Integers.
  get-height: (x, y) ->
    buffer_x = Math.floor x / CHUNK_SIZE
    buffer_y = Math.floor y / CHUNK_SIZE
    chunk_x = x - buffer_x * CHUNK_SIZE
    chunk_y = y - buffer_y * CHUNK_SIZE
    chunk_idx = chunk_x + chunk_y * CHUNK_SIZE
    chunk = @get-chunk buffer_x, buffer_y
    if chunk[chunk_idx] < 0
      chunk[chunk_idx] = perlin.pnoise2 x/100, y/100, 0.5, 4, SEED
    chunk[chunk_idx] * 3000
